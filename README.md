# screenshot付きエラーレポート送信サンプル

このブランチはエラー発生時にレポートを送信するサンプルです。

## 注意点

このプログラムを動かすには、Sentryで作成したプロジェクトのDSNの設定が必要です。

DSNとは？Sentryとは？といった方は下記を参照ください。

* https://docs.sentry.io/platforms/flutter/
* https://sentry.io/welcome/?utm_source=google&utm_medium=cpc&utm_campaign=9575834316&utm_content=g&utm_term=sentry&device=c&gclid=Cj0KCQjwidSWBhDdARIsAIoTVb1SQ6HmZwiqv4BKfEbsInaePWPKPLWJ4rjaR09obwO1A03IB91VqyoaAnlbEALw_wcB&gclid=Cj0KCQjwidSWBhDdARIsAIoTVb1SQ6HmZwiqv4BKfEbsInaePWPKPLWJ4rjaR09obwO1A03IB91VqyoaAnlbEALw_wcB

main.dartの下記部分を変更してください。

```dart
Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      // ↓↓↓ ここに自分のプロジェクトのdsnを設定
      options.dsn =
          'https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@xxxxxxxx.ingest.sentry.io/xxxxxxx';
      // ↑↑↑ ここに自分のプロジェクトのdsnを設定
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      const MyApp(),
    ),
  );
}
```
