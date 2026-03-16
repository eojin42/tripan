package com.tripan.app.service;

import java.net.URI;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripan.app.domain.dto.TripDto.WeatherHourlyItemDto;
import com.tripan.app.domain.dto.TripDto.WeatherMidDayDto;
import com.tripan.app.domain.dto.TripDto.WeatherResponseDto;
import com.tripan.app.domain.dto.TripDto.WeatherShortDayDto;

import lombok.extern.slf4j.Slf4j;

/**
 * 기상청 단기/중기 예보 API
 *
 * ★ 핵심 수정:
 *  - startDate/endDate 무시, 항상 오늘 기준 7일 예보 반환
 *  - base_date = 오늘, base_time = 현재 시각 기준 최신 발표 시각
 *  - 단기(D~D+3): 한 번 조회 후 fcstDate 필터링
 *  - 중기(D+4~D+7): getMidLandFcst + getMidTa
 */
@Slf4j
@Service
public class WeatherServiceImpl implements WeatherService {

    @Value("${tripan.api.kma-service-key}")
    private String serviceKey;

    @Value("${tripan.api.kma-base-url:https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0}")
    private String shortBaseUrl;

    @Value("${tripan.api.kma-mid-base-url:https://apis.data.go.kr/1360000/MidFcstInfoService}")
    private String midBaseUrl;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper  = new ObjectMapper();

    // ── 도시 → 단기예보 격자 좌표 (기상청 공식 엑셀 기준) ────────
    private static final Map<String, int[]> CITY_GRID = new LinkedHashMap<>();
    static {
        // 특별시/광역시
        CITY_GRID.put("서울",   new int[]{60, 127});
        CITY_GRID.put("인천",   new int[]{55, 124});
        CITY_GRID.put("대전",   new int[]{67, 100});
        CITY_GRID.put("대구",   new int[]{89,  90});
        CITY_GRID.put("광주",   new int[]{58,  74});
        CITY_GRID.put("부산",   new int[]{98,  76});
        CITY_GRID.put("울산",   new int[]{102, 84});
        CITY_GRID.put("세종",   new int[]{66, 103});
        // 경기/강원
        CITY_GRID.put("수원",   new int[]{60, 121});
        CITY_GRID.put("성남",   new int[]{63, 124});
        CITY_GRID.put("고양",   new int[]{57, 128});
        CITY_GRID.put("용인",   new int[]{64, 119});
        CITY_GRID.put("춘천",   new int[]{73, 134});
        CITY_GRID.put("원주",   new int[]{76, 122});
        CITY_GRID.put("강릉",   new int[]{92, 131});
        CITY_GRID.put("속초",   new int[]{87, 141});
        CITY_GRID.put("동해",   new int[]{97, 127});
        CITY_GRID.put("태백",   new int[]{95, 119});
        // 충청
        CITY_GRID.put("청주",   new int[]{69, 107});
        CITY_GRID.put("충주",   new int[]{76, 114});
        CITY_GRID.put("제천",   new int[]{81, 118});
        CITY_GRID.put("천안",   new int[]{63, 110});
        CITY_GRID.put("아산",   new int[]{60, 110});
        CITY_GRID.put("공주",   new int[]{63, 102});
        // 전라
        CITY_GRID.put("전주",   new int[]{63,  89});
        CITY_GRID.put("군산",   new int[]{56,  92});
        CITY_GRID.put("익산",   new int[]{60,  91});
        CITY_GRID.put("정읍",   new int[]{59,  83});
        CITY_GRID.put("남원",   new int[]{68,  80});
        CITY_GRID.put("광양",   new int[]{73,  70});
        CITY_GRID.put("순천",   new int[]{70,  70});
        CITY_GRID.put("여수",   new int[]{73,  66});
        CITY_GRID.put("목포",   new int[]{50,  67});
        CITY_GRID.put("나주",   new int[]{56,  71});
        CITY_GRID.put("해남",   new int[]{54,  61});
        // 경상
        CITY_GRID.put("포항",   new int[]{102, 94});
        CITY_GRID.put("경주",   new int[]{100, 91});
        CITY_GRID.put("구미",   new int[]{96,  97});
        CITY_GRID.put("안동",   new int[]{91, 106});
        CITY_GRID.put("창원",   new int[]{91,  77});
        CITY_GRID.put("진주",   new int[]{81,  75});
        CITY_GRID.put("거제",   new int[]{91,  72});
        CITY_GRID.put("통영",   new int[]{87,  72});
        // 제주
        CITY_GRID.put("제주",   new int[]{53,  38});
        CITY_GRID.put("서귀포", new int[]{53,  33});
        // 도 단위 (도청 소재지)
        CITY_GRID.put("경기",   new int[]{60, 120});
        CITY_GRID.put("강원",   new int[]{73, 134});
        CITY_GRID.put("충청",   new int[]{68, 100});
        CITY_GRID.put("전라",   new int[]{63,  89});
        CITY_GRID.put("경상",   new int[]{98,  76});
    }

    // ── 중기예보 지역코드 ─────────────────────────────────────────
    private static final Map<String, String> MID_LAND = new HashMap<>();
    private static final Map<String, String> MID_TA   = new HashMap<>();
    static {
        // 중기육상
        String[][] landData = {
            {"서울","11B00000"},{"인천","11B00000"},{"수원","11B00000"},{"성남","11B00000"},
            {"고양","11B00000"},{"용인","11B00000"},{"경기","11B00000"},
            {"춘천","11D10000"},{"원주","11D10000"},{"강원","11D10000"},
            {"강릉","11D20000"},{"속초","11D20000"},{"동해","11D20000"},{"태백","11D20000"},
            {"청주","11C10000"},{"충주","11C10000"},{"제천","11C10000"},
            {"대전","11C20000"},{"세종","11C20000"},{"천안","11C20000"},{"아산","11C20000"},{"공주","11C20000"},{"충청","11C20000"},
            {"전주","11F10000"},{"군산","11F10000"},{"익산","11F10000"},{"정읍","11F10000"},{"남원","11F10000"},
            {"광주","11F20000"},{"목포","11F20000"},{"나주","11F20000"},{"해남","11F20000"},
            {"순천","11F20000"},{"여수","11F20000"},{"광양","11F20000"},{"전라","11F20000"},
            {"대구","11H10000"},{"포항","11H10000"},{"경주","11H10000"},{"구미","11H10000"},{"안동","11H10000"},
            {"부산","11H20000"},{"울산","11H20000"},{"창원","11H20000"},{"진주","11H20000"},
            {"거제","11H20000"},{"통영","11H20000"},{"경상","11H20000"},
            {"제주","11G00000"},{"서귀포","11G00000"},
        };
        for (String[] r : landData) MID_LAND.put(r[0], r[1]);

        // 중기기온
        String[][] taData = {
            {"서울","11B10101"},{"인천","11B20201"},{"수원","11B20601"},{"성남","11B20605"},
            {"고양","11B20101"},{"용인","11B20612"},{"경기","11B20601"},
            {"춘천","11D10301"},{"원주","11D10401"},{"강원","11D10301"},
            {"강릉","11D20501"},{"속초","11D20401"},{"동해","11D20601"},{"태백","11D20601"},
            {"청주","11C10201"},{"충주","11C10301"},{"제천","11C10501"},
            {"대전","11C20401"},{"세종","11C20404"},{"천안","11C20101"},{"아산","11C20103"},{"공주","11C20301"},{"충청","11C20401"},
            {"전주","11F10201"},{"군산","11F10101"},{"익산","11F10203"},{"정읍","11F10401"},{"남원","11F10301"},
            {"광주","11F20501"},{"목포","11F20301"},{"나주","11F20503"},{"해남","11F20401"},
            {"순천","11F20402"},{"여수","11F20401"},{"광양","11F20402"},{"전라","11F20501"},
            {"대구","11H10701"},{"포항","11H10201"},{"경주","11H10601"},{"구미","11H10502"},{"안동","11H10501"},
            {"부산","11H20201"},{"울산","11H20101"},{"창원","11H20301"},{"진주","11H20401"},
            {"거제","11H20601"},{"통영","11H20501"},{"경상","11H20201"},
            {"제주","11G00201"},{"서귀포","11G00401"},
        };
        for (String[] r : taData) MID_TA.put(r[0], r[1]);
    }

    // ══════════════════════════════════════════════════════════════
    //  메인 진입점 — startDate/endDate 는 무시하고 오늘 기준 7일
    // ══════════════════════════════════════════════════════════════
    @Override
    public WeatherResponseDto getWeather(String cityRaw, String startDateStr, String endDateStr) {
        String    city  = normalizeCity(cityRaw);
        LocalDate today = LocalDate.now();
        LocalDate end7  = today.plusDays(6); // 오늘 포함 7일

        WeatherResponseDto dto = new WeatherResponseDto();
        dto.setCity(city);

        // D~D+3 단기예보 (한 번 API 호출로 4일치)
        List<WeatherShortDayDto> shortList = fetchShortForDates(city, today, today.plusDays(3));
        // D+4~D+6 중기예보
        List<WeatherMidDayDto> midList = fetchMidForecast(city, today.plusDays(4), end7);

        dto.setShortForecast(shortList);
        dto.setMidForecast(midList);
        dto.setFarFuture(false);
        dto.setHasDistantDays(false);
        dto.setClimateNote(null);
        return dto;
    }

    // ══════════════════════════════════════════════════════════════
    //  단기예보 (D~D+3) — base_date=오늘, 날짜별 필터링
    // ══════════════════════════════════════════════════════════════
    private List<WeatherShortDayDto> fetchShortForDates(String city, LocalDate from, LocalDate to) {
        int[] g = CITY_GRID.getOrDefault(city, CITY_GRID.get("서울"));

        // 오늘 기준 최신 발표 시각 (02/05/08/11/14/17/20/23시)
        LocalDate today   = LocalDate.now();
        LocalTime nowTime = LocalTime.now(ZoneId.of("Asia/Seoul"));
        int[] SLOTS = {2, 5, 8, 11, 14, 17, 20, 23};
        int baseHour = 2;
        for (int bt : SLOTS) { if (nowTime.getHour() >= bt + 1) baseHour = bt; }

        LocalDate baseDate;
        String    baseTime;
        if (baseHour == 2 && nowTime.getHour() < 3) {
            baseDate = today.minusDays(1);
            baseTime = "2300";
        } else {
            baseDate = today;
            baseTime = String.format("%02d00", baseHour);
        }

        log.info("[Weather] 단기예보 city={} nx={} ny={} base_date={} base_time={}",
            city, g[0], g[1], baseDate, baseTime);

        try {
            URI uri = UriComponentsBuilder
                .fromUriString(shortBaseUrl + "/getVilageFcst")
                .queryParam("ServiceKey", serviceKey)
                .queryParam("pageNo",    "1")
                .queryParam("numOfRows", "1500")
                .queryParam("dataType",  "JSON")
                .queryParam("base_date", baseDate.format(DateTimeFormatter.ofPattern("yyyyMMdd")))
                .queryParam("base_time", baseTime)
                .queryParam("nx", g[0])
                .queryParam("ny", g[1])
                .build(true).toUri();

            HttpHeaders h = new HttpHeaders();
            h.set("Accept", "application/json");
            String body = restTemplate.exchange(uri, HttpMethod.GET, new HttpEntity<>(h), String.class).getBody();

            if (body == null) { log.warn("[Weather] 응답 null city={}", city); return List.of(); }

            // 기상청 오류코드 체크
            if (body.contains("\"resultCode\":\"03\"") || body.contains("\"resultCode\":\"04\"")) {
                log.warn("[Weather] API 오류코드 city={} → 전날 2300으로 재시도", city);
                return fetchShortFallback(city, g, from, to);
            }

            JsonNode items = objectMapper.readTree(body)
                .path("response").path("body").path("items").path("item");
            log.info("[Weather] 단기예보 응답 items={}", items.size());

            List<WeatherShortDayDto> result = new ArrayList<>();
            for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
                WeatherShortDayDto day = parseShortDay(items, d);
                if (day != null) result.add(day);
                else log.warn("[Weather] fcstDate={} 파싱 실패 (items={})", d, items.size());
            }
            return result;

        } catch (Exception e) {
            log.error("[Weather] 단기예보 실패 city={}: {}", city, e.getMessage());
            return List.of();
        }
    }

    private List<WeatherShortDayDto> fetchShortFallback(String city, int[] g, LocalDate from, LocalDate to) {
        try {
            LocalDate yd = LocalDate.now().minusDays(1);
            URI uri = UriComponentsBuilder
                .fromUriString(shortBaseUrl + "/getVilageFcst")
                .queryParam("ServiceKey", serviceKey)
                .queryParam("pageNo",    "1")
                .queryParam("numOfRows", "1500")
                .queryParam("dataType",  "JSON")
                .queryParam("base_date", yd.format(DateTimeFormatter.ofPattern("yyyyMMdd")))
                .queryParam("base_time", "2300")
                .queryParam("nx", g[0]).queryParam("ny", g[1])
                .build(true).toUri();
            HttpHeaders h = new HttpHeaders();
            h.set("Accept", "application/json");
            String body = restTemplate.exchange(uri, HttpMethod.GET, new HttpEntity<>(h), String.class).getBody();
            JsonNode items = objectMapper.readTree(body).path("response").path("body").path("items").path("item");
            List<WeatherShortDayDto> result = new ArrayList<>();
            for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
                WeatherShortDayDto day = parseShortDay(items, d);
                if (day != null) result.add(day);
            }
            return result;
        } catch (Exception e) {
            log.error("[Weather] fallback 실패: {}", e.getMessage());
            return List.of();
        }
    }

    private WeatherShortDayDto parseShortDay(JsonNode items, LocalDate date) {
        if (items == null || !items.isArray()) return null;
        String target = date.format(DateTimeFormatter.ofPattern("yyyyMMdd"));

        Map<String, Map<String, String>> hourMap = new TreeMap<>();
        for (JsonNode item : items) {
            if (!target.equals(item.path("fcstDate").asText())) continue;
            String hh  = item.path("fcstTime").asText().substring(0, 2);
            String cat = item.path("category").asText();
            String val = item.path("fcstValue").asText();
            hourMap.computeIfAbsent(hh, k -> new HashMap<>()).put(cat, val);
        }
        if (hourMap.isEmpty()) return null;

        int tmax = Integer.MIN_VALUE, tmin = Integer.MAX_VALUE;
        List<WeatherHourlyItemDto> hourly = new ArrayList<>();
        for (Map.Entry<String, Map<String, String>> e : hourMap.entrySet()) {
            Map<String, String> v = e.getValue();
            int temp = v.containsKey("TMP") ? (int) Math.round(Double.parseDouble(v.get("TMP"))) : 0;
            tmax = Math.max(tmax, temp); tmin = Math.min(tmin, temp);
            WeatherHourlyItemDto h = new WeatherHourlyItemDto();
            h.setTime(e.getKey()); h.setTemp(temp);
            h.setSky(skyCode(v.getOrDefault("SKY","1"), v.getOrDefault("PTY","0")));
            h.setRainProb(v.containsKey("POP") ? Integer.parseInt(v.get("POP")) : 0);
            h.setRainType(ptyCode(v.getOrDefault("PTY","0")));
            hourly.add(h);
        }

        WeatherShortDayDto day = new WeatherShortDayDto();
        day.setDate(date.toString());
        day.setDayLabel(dayLabel(date));
        day.setHourly(hourly);
        day.setTmax(tmax == Integer.MIN_VALUE ? null : tmax);
        day.setTmin(tmin == Integer.MAX_VALUE ? null : tmin);
        return day;
    }

    // ══════════════════════════════════════════════════════════════
    //  중기예보 (D+4~D+6) — 최대 7일까지
    // ══════════════════════════════════════════════════════════════
    private List<WeatherMidDayDto> fetchMidForecast(String city, LocalDate from, LocalDate to) {
        String landCode = MID_LAND.getOrDefault(city, "11B00000");
        String taCode   = MID_TA.getOrDefault(city,   "11B10101");
        LocalDate today = LocalDate.now();
        LocalTime now   = LocalTime.now(ZoneId.of("Asia/Seoul"));
        // 중기예보 발표: 06시(06:30 이후 제공), 18시(18:30 이후 제공)
        // 현재 시각 기준 가장 최근 발표 tmFc 계산
        String tmFc;
        if (now.getHour() > 18 || (now.getHour() == 18 && now.getMinute() >= 30)) {
            tmFc = today.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "1800";
        } else if (now.getHour() > 6 || (now.getHour() == 6 && now.getMinute() >= 30)) {
            tmFc = today.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "0600";
        } else {
            // 새벽 ~ 06:30 이전 → 전날 18시 발표 사용
            tmFc = today.minusDays(1).format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "1800";
        }
        log.info("[Weather] 중기예보 city={} tmFc={} landCode={} taCode={}", city, tmFc, landCode, taCode);

        // 대상 날짜 맵 초기화
        Map<String, WeatherMidDayDto> dtoMap = new LinkedHashMap<>();
        for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
            WeatherMidDayDto dto = new WeatherMidDayDto();
            dto.setDate(d.toString()); dto.setDayLabel(dayLabel(d));
            dtoMap.put(d.toString(), dto);
        }
        if (dtoMap.isEmpty()) return List.of();

        // 중기육상
        try {
            URI uri = UriComponentsBuilder.fromUriString(midBaseUrl + "/getMidLandFcst")
                .queryParam("ServiceKey", serviceKey).queryParam("dataType","JSON")
                .queryParam("regId", landCode).queryParam("tmFc", tmFc)
                .build(true).toUri();
            String body = restTemplate.exchange(uri, HttpMethod.GET, new HttpEntity<>(new HttpHeaders()), String.class).getBody();
            JsonNode arr = objectMapper.readTree(body).path("response").path("body").path("items").path("item");
            if (arr.isArray() && arr.size() > 0) parseMidLand(arr.get(0), dtoMap, today);
        } catch (Exception e) { log.warn("[Weather] 중기육상 실패 {}: {}", city, e.getMessage()); }

        // 중기기온
        try {
            URI uri = UriComponentsBuilder.fromUriString(midBaseUrl + "/getMidTa")
                .queryParam("ServiceKey", serviceKey).queryParam("dataType","JSON")
                .queryParam("regId", taCode).queryParam("tmFc", tmFc)
                .build(true).toUri();
            String body = restTemplate.exchange(uri, HttpMethod.GET, new HttpEntity<>(new HttpHeaders()), String.class).getBody();
            JsonNode arr = objectMapper.readTree(body).path("response").path("body").path("items").path("item");
            if (arr.isArray() && arr.size() > 0) parseMidTa(arr.get(0), dtoMap, today);
        } catch (Exception e) { log.warn("[Weather] 중기기온 실패 {}: {}", city, e.getMessage()); }

        return new ArrayList<>(dtoMap.values());
    }

    private void parseMidLand(JsonNode item, Map<String, WeatherMidDayDto> map, LocalDate today) {
        for (int i = 3; i <= 10; i++) {
            String key = today.plusDays(i).toString();
            if (!map.containsKey(key)) continue;
            WeatherMidDayDto d = map.get(key);
            d.setAmDesc(item.path("wf"+i+"Am").asText(""));
            d.setPmDesc(item.path("wf"+i+"Pm").asText(""));
            d.setRainProb(Math.max(item.path("rnSt"+i+"Am").asInt(0), item.path("rnSt"+i+"Pm").asInt(0)));
        }
    }

    private void parseMidTa(JsonNode item, Map<String, WeatherMidDayDto> map, LocalDate today) {
        for (int i = 3; i <= 10; i++) {
            String key = today.plusDays(i).toString();
            if (!map.containsKey(key)) continue;
            WeatherMidDayDto d = map.get(key);
            int tn = item.path("taMin"+i).asInt(Integer.MIN_VALUE);
            int tx = item.path("taMax"+i).asInt(Integer.MIN_VALUE);
            if (tn != Integer.MIN_VALUE) d.setTmin(tn);
            if (tx != Integer.MIN_VALUE) d.setTmax(tx);
        }
    }

    // ── 유틸 ─────────────────────────────────────────────────────
    private String skyCode(String sky, String pty) {
        if (!"0".equals(pty)) switch(pty){
            case"1":return"비"; case"2":return"비/눈"; case"3":return"눈"; case"4":return"소나기"; default:return"강수";
        }
        switch(sky){ case"1":return"맑음"; case"3":return"구름많음"; case"4":return"흐림"; default:return"맑음"; }
    }
    private String ptyCode(String p) {
        switch(p){ case"1":return"비"; case"2":return"비/눈"; case"3":return"눈"; case"4":return"소나기"; default:return"없음"; }
    }
    private String dayLabel(LocalDate d) {
        return d.getMonthValue() + "/" + d.getDayOfMonth()
            + " " + d.getDayOfWeek().getDisplayName(TextStyle.SHORT, java.util.Locale.KOREAN);
    }
    private String normalizeCity(String raw) {
        if (raw == null || raw.isBlank()) return "서울";
        String c = raw.trim();
        if (CITY_GRID.containsKey(c)) return c;
        if (c.startsWith("서귀포")) return "서귀포";
        if (c.startsWith("제주"))   return "제주";
        if (c.startsWith("부산"))   return "부산";
        if (c.startsWith("서울"))   return "서울";
        if (c.startsWith("인천"))   return "인천";
        if (c.startsWith("대전"))   return "대전";
        if (c.startsWith("대구"))   return "대구";
        if (c.startsWith("광주"))   return "광주";
        if (c.startsWith("울산"))   return "울산";
        if (c.startsWith("세종"))   return "세종";
        if (c.startsWith("강원"))   return "강원";
        if (c.contains("경기"))     return "경기";
        if (c.contains("충청")||c.contains("충북")||c.contains("충남")) return "충청";
        if (c.contains("전라")||c.contains("전북")||c.contains("전남")) return "전라";
        if (c.contains("경상")||c.contains("경북")||c.contains("경남")) return "경상";
        // 앞 2글자 재시도
        String p2 = c.length() >= 2 ? c.substring(0,2) : c;
        if (CITY_GRID.containsKey(p2)) return p2;
        log.warn("[Weather] 알 수 없는 도시 '{}' → 서울 폴백", raw);
        return "서울";
    }
}
