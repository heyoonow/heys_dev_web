import 'package:universal_html/html.dart' as html;

class HeysTool {
  //region: meta 태그 설정
  static void setMetaTags({
    String? title,
    String? description,
    String? imageUrl,
    String? url,
    String? keywords,
    String? siteName,
    String? ogType,
    String? twitterCard,
  }) {
    // 1. 기본값 (영어)
    final defaultTitle = "heys.dev - The Best Developer Toolbox";
    final defaultDesc =
        "heys.dev is a free, powerful toolbox for developers and designers.";
    final defaultImg = "https://heys.dev/your_og_image.png";
    final defaultUrl = html.window.location.href;
    final defaultSiteName = "heys.dev";
    final defaultOgType = "website";
    final defaultTwitterCard = "summary_large_image";

    // 2. 기존 meta/link 태그 제거 (중복방지)
    html.document.head!
        .querySelectorAll(
          'meta[name="description"],meta[name="keywords"],meta[property="og:title"],meta[property="og:description"],meta[property="og:image"],meta[property="og:url"],meta[property="og:site_name"],meta[property="og:type"],meta[name="twitter:title"],meta[name="twitter:description"],meta[name="twitter:image"],meta[name="twitter:card"],link[rel="canonical"]',
        )
        .forEach((e) => e.remove());

    // 3. title
    html.document.title = (title != null && title.trim().isNotEmpty)
        ? title
        : defaultTitle;

    // 4. description
    final metaDesc = html.MetaElement()
      ..name = "description"
      ..content = (description != null && description.trim().isNotEmpty)
          ? description
          : defaultDesc;
    html.document.head!.append(metaDesc);

    // 5. keywords
    if (keywords != null && keywords.trim().isNotEmpty) {
      final metaKeywords = html.MetaElement()
        ..name = "keywords"
        ..content = keywords;
      html.document.head!.append(metaKeywords);
    }

    // 6. canonical
    final canonical = html.LinkElement()
      ..rel = "canonical"
      ..href = (url != null && url.trim().isNotEmpty) ? url : defaultUrl;
    html.document.head!.append(canonical);

    // 7. og 태그
    final ogTitle = html.MetaElement()
      ..setAttribute("property", "og:title")
      ..content = (title != null && title.trim().isNotEmpty)
          ? title
          : defaultTitle;
    html.document.head!.append(ogTitle);

    final ogDesc = html.MetaElement()
      ..setAttribute("property", "og:description")
      ..content = (description != null && description.trim().isNotEmpty)
          ? description
          : defaultDesc;
    html.document.head!.append(ogDesc);

    final ogImage = html.MetaElement()
      ..setAttribute("property", "og:image")
      ..content = (imageUrl != null && imageUrl.trim().isNotEmpty)
          ? imageUrl
          : defaultImg;
    html.document.head!.append(ogImage);

    final ogUrl = html.MetaElement()
      ..setAttribute("property", "og:url")
      ..content = (url != null && url.trim().isNotEmpty) ? url : defaultUrl;
    html.document.head!.append(ogUrl);

    final ogSiteName = html.MetaElement()
      ..setAttribute("property", "og:site_name")
      ..content = (siteName != null && siteName.trim().isNotEmpty)
          ? siteName
          : defaultSiteName;
    html.document.head!.append(ogSiteName);

    final ogTypeElem = html.MetaElement()
      ..setAttribute("property", "og:type")
      ..content = (ogType != null && ogType.trim().isNotEmpty)
          ? ogType
          : defaultOgType;
    html.document.head!.append(ogTypeElem);

    // 8. twitter 태그
    final twitterTitle = html.MetaElement()
      ..name = "twitter:title"
      ..content = (title != null && title.trim().isNotEmpty)
          ? title
          : defaultTitle;
    html.document.head!.append(twitterTitle);

    final twitterDesc = html.MetaElement()
      ..name = "twitter:description"
      ..content = (description != null && description.trim().isNotEmpty)
          ? description
          : defaultDesc;
    html.document.head!.append(twitterDesc);

    final twitterImage = html.MetaElement()
      ..name = "twitter:image"
      ..content = (imageUrl != null && imageUrl.trim().isNotEmpty)
          ? imageUrl
          : defaultImg;
    html.document.head!.append(twitterImage);

    final twitterCardElem = html.MetaElement()
      ..name = "twitter:card"
      ..content = (twitterCard != null && twitterCard.trim().isNotEmpty)
          ? twitterCard
          : defaultTwitterCard;
    html.document.head!.append(twitterCardElem);
  }

  //endregion
}
