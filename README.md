# InputExc
An application that converts (Bluetooth)gamepad input to keyboard

## Usage

TABMATEのボタンそれぞれに、簡単なキーボード入力の組み合わせが出来ます。

モード切り替えにも対応しています。

割り当てたいボタンのテキストフィールドを選んで、キーボードのボタンを押す事で入力が設定されます。

値を変更したらUpdateボタンを押す事で反映されます。また、次回以降もその設定を使用したい場合は、Saveボタンを押す事で設定が保存され、次回から設定が反映された状態で起動されます。

設定はユーザーのホームフォルダに .InputExc/configure.json という名称で保存されます。初期状態に戻すにはファイルを削除してください。

設定したい値がEnterやEscといった、文字として入力不可能なものの場合は、以下の文字列を設定する事で動作させる事が出来ます。

* RETURN, TAB, SPACE, DELETE, ESCAPE, END
* F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12
* HELP, HOME, PGUP, PGDN
* LEFT, RIGHT, DOWN, UP

## 初回起動時のプライバシー警告について

IntpuExcの動作は「入力の監視」と「アクセシビリティ」に対して許可が必要です。

許可がない場合は、アプリ画面に

* IOHIDManagerOpen error
* IOHIDDeviceOpen error

といった表示がされます。

利用する場合は、システム環境設定を開き、セキュリティとプライバシー > プライバシーを選択して、以下の項目にチェックを入れてください。

* アクセシビリティのInputExp.app
* 入力監視のInputExp.app
