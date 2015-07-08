導入手順
1.Measurement.h、Measurement.mをプロジェクトにコピー

概要
丸め誤差を考慮して、秒、ミリ秒、マイクロ秒、ナノ秒単位で処理時間を計測


使い方
・計測開始
[Measurement measure_start];

・計測終了
[Measurement measure_end];

[Measurement resultMeasureTime:表示単位のオプション];
オプション
Sec:秒で表示
miriSec:ミリ秒で表示
microSec:マイクロ秒で表示
nanoSec:ナノ秒で表示
    