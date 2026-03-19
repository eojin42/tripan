package com.tripan.app.mail;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * 파트너 관리 메일 HTML 템플릿
 * PartnerManageServiceImpl 의 approvePartner / rejectPartner 에서 호출
 */
public class PartnerMailTemplates {

    private static final String SITE_URL    = "https://tripan.com/partner/main";
    private static final String SUPPORT     = "support@tripan.com";
    private static final String GRAD_START  = "#89CFF0";  // 파스텔 스카이 블루
    private static final String GRAD_END    = "#FFB6C1";  // 파스텔 라이트 핑크

    // ── 공통 헤더 ────────────────────────────────────────────
    private static String header(String badgeText, String badgeEmoji) {
        return """
            <!DOCTYPE html>
            <html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
            <body style="margin:0;padding:0;background:#f4f7fb;font-family:'Apple SD Gothic Neo',AppleSDGothic,'Noto Sans KR',Arial,sans-serif;">
            <table width="100%%" cellpadding="0" cellspacing="0" style="background:#f4f7fb;padding:48px 0;">
            <tr><td align="center">
            <table width="580" cellpadding="0" cellspacing="0"
                   style="background:#ffffff;border-radius:24px;overflow:hidden;box-shadow:0 8px 40px rgba(137,207,240,0.18);max-width:580px;">

              <!-- ── 그라디언트 헤더 ── -->
              <tr>
                <td style="background:linear-gradient(135deg,%s 0%%,%s 100%%);padding:44px 40px 36px;text-align:center;">

                  <!-- 로고 -->
                  <table cellpadding="0" cellspacing="0" style="margin:0 auto 6px;">
                    <tr>
                      <td style="vertical-align:baseline;">
                        <span style="font-size:34px;font-weight:900;color:#ffffff;letter-spacing:-1px;">Tri</span>
                      </td>
                      <td style="vertical-align:baseline;position:relative;">
                        <span style="font-size:34px;font-weight:900;color:rgba(255,255,255,0.88);letter-spacing:-1px;">pan</span>
                        <!-- 비행기 라인 (인라인 SVG) -->
                        <div style="position:relative;height:5px;margin-top:2px;">
                          <div style="height:3px;background:rgba(255,255,255,0.5);border-radius:2px;"></div>
                          <span style="position:absolute;right:-2px;top:-9px;font-size:14px;">✈</span>
                        </div>
                      </td>
                      <td style="vertical-align:baseline;padding-left:1px;">
                        <span style="font-size:38px;font-weight:900;color:#FFB6C1;line-height:0;vertical-align:bottom;">.</span>
                      </td>
                    </tr>
                  </table>

                  <div style="font-size:12px;color:rgba(255,255,255,0.75);letter-spacing:1.5px;text-transform:uppercase;margin-top:2px;">
                    Partner Management System
                  </div>

                  <!-- 배지 -->
                  <div style="margin-top:24px;display:inline-block;background:rgba(255,255,255,0.22);
                              border:1.5px solid rgba(255,255,255,0.5);border-radius:50px;padding:10px 28px;">
                    <span style="font-size:15px;font-weight:800;color:#ffffff;letter-spacing:0.3px;">
                      %s %s
                    </span>
                  </div>

                </td>
              </tr>
            """.formatted(GRAD_START, GRAD_END, badgeEmoji, badgeText);
    }

    // ── 공통 푸터 ────────────────────────────────────────────
    private static String footer() {
        return """
              <!-- ── CTA 버튼 ── -->
              <tr>
                <td style="padding:4px 40px 32px;text-align:center;">
                  <a href="%s"
                     style="display:inline-block;
                            background:linear-gradient(135deg,%s 0%%,%s 100%%);
                            color:#ffffff;font-size:14px;font-weight:800;
                            text-decoration:none;padding:15px 40px;
                            border-radius:50px;letter-spacing:0.4px;
                            box-shadow:0 4px 16px rgba(137,207,240,0.4);">
                    파트너 사이트 바로가기 &nbsp;→
                  </a>
                </td>
              </tr>

              <!-- ── 구분선 ── -->
              <tr><td style="padding:0 40px;"><div style="height:1px;background:#f0f0f0;"></div></td></tr>

              <!-- ── 푸터 ── -->
              <tr>
                <td style="padding:24px 40px;text-align:center;">
                  <p style="font-size:12px;color:#bbb;margin:0;line-height:1.8;">
                    본 메일은 TRIPAN 파트너 관리 시스템에서 자동 발송된 메일입니다.<br>
                    문의사항은 <a href="mailto:%s" style="color:#89CFF0;text-decoration:none;">%s</a>로 연락해 주세요.
                  </p>
                  <p style="font-size:11px;color:#ddd;margin:8px 0 0;">
                    © 2025 TRIPAN. All rights reserved.
                  </p>
                </td>
              </tr>

            </table>
            </td></tr></table>
            </body></html>
            """.formatted(SITE_URL, GRAD_START, GRAD_END, SUPPORT, SUPPORT);
    }

    // ── 정보 행 헬퍼 ─────────────────────────────────────────
    private static String infoRow(String label, String value, boolean isFirst) {
        String border = isFirst ? "" : "border-top:1px solid #e8f5fd;";
        return """
            <tr>
              <td width="130" style="font-size:13px;color:#999;font-weight:600;padding:10px 0;%s">%s</td>
              <td style="font-size:13px;color:#333;font-weight:700;padding:10px 0;%s">%s</td>
            </tr>
            """.formatted(border, label, border, value);
    }

    // ════════════════════════════════════════════════════════
    //  승인 메일
    // ════════════════════════════════════════════════════════
    public static String approveSubject() {
        return "[TRIPAN] 파트너사 입점 신청이 승인되었습니다 🎉";
    }

    public static String approveContent(String partnerName, Double commissionRate, Date contractEndDate) {
        String rate    = commissionRate != null ? String.format("%.1f", commissionRate) + "%" : "별도 안내";
        String endDate = contractEndDate != null
            ? new SimpleDateFormat("yyyy년 MM월 dd일").format(contractEndDate) : "별도 안내";

        String infoBox = """
            <table width="100%%" cellpadding="0" cellspacing="0"
                   style="background:#f0f9ff;border-radius:14px;border-left:4px solid #89CFF0;">
              <tr><td style="padding:20px 24px;">
                <p style="font-size:11px;font-weight:800;color:#89CFF0;
                          text-transform:uppercase;letter-spacing:1px;margin:0 0 12px;">
                  계약 정보
                </p>
                <table width="100%%" cellpadding="0" cellspacing="0">
                  %s%s%s
                </table>
              </td></tr>
            </table>
            """.formatted(
                infoRow("파트너사명", "<strong>" + partnerName + "</strong>", true),
                infoRow("중개 수수료율", "<span style='color:#5bb8e8;font-size:15px;font-weight:900;'>" + rate + "</span>", false),
                infoRow("계약 종료일", endDate, false)
            );

        return header("입점 심사 승인 완료", "✅") + """
              <!-- ── 본문 ── -->
              <tr>
                <td style="padding:36px 40px 20px;">
                  <p style="font-size:16px;font-weight:700;color:#222;margin:0 0 8px;">
                    안녕하세요, <span style="color:#5bb8e8;">%s</span> 담당자님! 👋
                  </p>
                  <p style="font-size:14px;color:#666;line-height:1.8;margin:0 0 24px;">
                    TRIPAN 파트너사 입점 심사가 <strong style="color:#333;">최종 승인</strong>되었습니다.<br>
                    아래 계약 정보를 확인하시고 파트너 사이트에서 서비스를 시작해 보세요.
                  </p>
                  %s
                </td>
              </tr>
            """.formatted(partnerName, infoBox)
            + footer();
    }

    // ════════════════════════════════════════════════════════
    //  반려 메일
    // ════════════════════════════════════════════════════════
    public static String rejectSubject() {
        return "[TRIPAN] 파트너사 입점 신청 반려 안내";
    }

    public static String rejectContent(String partnerName, String rejectReason) {
        String reasonBox = """
            <table width="100%%" cellpadding="0" cellspacing="0"
                   style="background:#fff5f5;border-radius:14px;border-left:4px solid #FFB6C1;">
              <tr><td style="padding:20px 24px;">
                <p style="font-size:11px;font-weight:800;color:#e08090;
                          text-transform:uppercase;letter-spacing:1px;margin:0 0 10px;">
                  반려 사유
                </p>
                <p style="font-size:14px;color:#555;line-height:1.7;margin:0;">%s</p>
              </td></tr>
            </table>
            """.formatted(rejectReason != null ? rejectReason : "-");

        return header("입점 심사 반려 안내", "📋") + """
              <!-- ── 본문 ── -->
              <tr>
                <td style="padding:36px 40px 20px;">
                  <p style="font-size:16px;font-weight:700;color:#222;margin:0 0 8px;">
                    안녕하세요, <span style="color:#5bb8e8;">%s</span> 담당자님.
                  </p>
                  <p style="font-size:14px;color:#666;line-height:1.8;margin:0 0 24px;">
                    TRIPAN 파트너사 입점 심사 결과, 아쉽게도 이번 신청은 <strong style="color:#e08090;">반려</strong>되었습니다.<br>
                    아래 반려 사유를 확인하신 후 내용을 보완하여 재신청해 주시기 바랍니다.
                  </p>
                  %s
                  <p style="font-size:13px;color:#999;line-height:1.7;margin:20px 0 0;">
                    궁금하신 사항은 <a href="mailto:%s" style="color:#89CFF0;text-decoration:none;font-weight:700;">%s</a>로 문의해 주세요.
                  </p>
                </td>
              </tr>
            """.formatted(partnerName, reasonBox, SUPPORT, SUPPORT)
            + footer();
    }
}
