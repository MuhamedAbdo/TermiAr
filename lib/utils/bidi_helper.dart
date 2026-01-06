import 'package:flutter/material.dart';

class BiDiHelper {
  // رموز اليونيكود للتحكم الصارم في النصوص ثنائية الاتجاه
  static const String rtlEmbed = '\u202B'; // بداية سياق يمين إلى يسار (عربي)
  static const String ltrEmbed = '\u202A'; // بداية سياق يسار إلى يمين (إنجليزي)
  static const String popEmbed = '\u202C'; // إغلاق السياق المعزول
  static const String rtlMark  = '\u200F'; // علامة يمين إلى يسار بسيطة

  /// للنصوص البسيطة والمختلطة في القوائم والعناوين (مثل أسماء الأوامر والفئات)
  static Widget buildMixedText({
    required String text,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final hasArabic = text.contains(RegExp(r'[\u0600-\u06FF]'));
    
    // تغليف النص بـ Embed لضمان استقرار ترتيب الكلمات الإنجليزية داخل الجملة العربية
    final processedText = hasArabic ? '$rtlEmbed$text$popEmbed' : text;

    return Directionality(
      textDirection: hasArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Text(
        processedText,
        style: style,
        textAlign: textAlign ?? (hasArabic ? TextAlign.right : TextAlign.left),
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }

  /// للنصوص الطويلة والمعقدة (الوصف، كيفية الاستخدام) التي تحتوي على روابط وأوامر
  static Widget buildRichTextWithCommands({
    required String text,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final spans = <InlineSpan>[];
    // ريجكس يلتقط الروابط، الأوامر بين ' '، والكلمات الإنجليزية التقنية
    final regex = RegExp(r"(https?://[^\s]+|'[^']+'|[a-zA-Z0-9\.:/_-]+)");
    int lastEnd = 0;

    // نبدأ دائماً بعلامة RTL لضمان التزام علامات الترقيم (النقطة) بالجهة اليسرى
    spans.add(const TextSpan(text: rtlMark));

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        // إضافة النص العربي المحيط
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      // عزل النص الإنجليزي (أمر أو رابط) تماماً لمنع قفز الكلمات العربية حوله
      spans.add(TextSpan(
        text: '$ltrEmbed${match.group(0)}$popEmbed',
        style: style?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
          fontFamily: 'monospace',
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    
    spans.add(const TextSpan(text: rtlMark));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RichText(
        textAlign: textAlign ?? TextAlign.right,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.visible,
        text: TextSpan(
          style: style,
          children: spans,
        ),
      ),
    );
  }
}