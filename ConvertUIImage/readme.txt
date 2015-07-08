導入手順
1.UUID.h、UUID.mをプロジェクトにコピー
2.UUID.mファイルのUUIDkeyNameに任意のkey名を入力

使い方

[UUID getUUID]
SHA512ver-UUIDをNSString型で返却。

[UUID deleteKeyChain]
対象プロジェクトのキーチェーンを削除。
※デバッグモード時のみ有効

その他は割愛