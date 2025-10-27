[![CI/CD Status](https://github.com/mustafakame1992g-arch/al_faw_zakho_new/actions/workflows/flutter.yml/badge.svg?branch=main)](https://github.com/mustafakame1992g-arch/al_faw_zakho_new/actions/workflows/flutter.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.19-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3-blue.svg)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# 🇮🇶 تطبيق الفاو زاخو

**تطبيق Flutter متقدم يعمل بنظام Offline-First** لعرض المعلومات الانتخابية لجميع محافظات العراق (19 محافظة) مع تجربة مستخدم سلسة ومتكاملة.

## 🎯 الرؤية

بناء منصة انتخابية عراقية توفر:
- ✅ **تجربة فورية** - عمل كامل بدون اتصال بالإنترنت
- 🚀 **أداء فائق** - تحميل فوري واستجابة سريعة
- 📱 **واجهة متكاملة** - دعم كامل للغة العربية والإنجليزية
- 📊 **تحليلات ذكية** - تتبع دقيق للأداء والأحداث

## ✨ المميزات الأساسية

### 🗳️ المحتوى الانتخابي
- **19 محافظة** عراقية بتفاصيل كاملة
- **المرشحين** - صور ومعلومات تفصيلية
- **المكاتب الانتخابية** - مواقع وخدمات
- **الأخبار** - آخر التحديثات
- **الأسئلة الشائعة** - إجابات وافية

### 🛠️ التقنيات المتقدمة
- **Offline-First** - تخزين محلي مع Hive
- **إدارة حالة** - Provider لنظام متكامل
- **ثنائية اللغة** - واجهة عربية/إنجليزية
- **السمات الديناميكية** - فاتح/مظلم/تلقائي
- **تتبع الأداء** - تحليلات وقياسات زمنية

## 🏗️ البنية التقنية

```yaml
dependencies:
  flutter: ^3.19.0
  provider: ^6.1.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  connectivity_plus: ^5.0.1
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
  flutter_lints: ^3.0.0