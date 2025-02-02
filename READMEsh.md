# SSL Certificate Checker

## 概要
このシェルスクリプトは、`domains.txt` に記載された各ドメイン（`host:port` 形式）に対して OpenSSL の `s_client` コマンドを利用し、SSL 証明書の情報（Subject、Issuer、有効期間など）を取得するためのツールです。  
接続に成功した場合は、証明書情報を `output/success` ディレクトリに保存し、接続に失敗した場合はエラー情報を `output/error` に出力します。  
また、スクリプトは並列処理を利用して最大 5 件まで同時にジョブを実行します。

## 特徴
- **ドメインリストの処理**: 各行が `host:port` 形式の `domains.txt` から対象を読み込みます。
- **SSL 証明書情報の取得**: OpenSSL の `s_client` と `x509` コマンドを使用して、証明書の件名（Subject）、発行者（Issuer）、および有効期間（notBefore, notAfter）を抽出します。
- **プロキシ経由の接続対応**:  
  特定のホスト（例: `sub.example.com`）に対しては、プロキシ経由で接続するためのオプションを設定します。  
  ※ただし、プロキシ接続は OpenSSL のバージョンに依存します。
- **並列処理**: 最大 5 件のジョブを同時に実行し、処理の高速化を図ります。
- **エラーハンドリング**:  
  `set -euo pipefail` を使用せず、各処理毎にエラー状態をチェックするように実装されています。

## 依存関係
- **OpenSSL**  
  - **Rocky Linux 9 (または RHEL 9 系)**  
    OpenSSL 3.x が搭載されており、`s_client` の `-proxy` オプションが利用可能です。  
  - **Rocky Linux 8 (または RHEL 8 系)**  
    OpenSSL 1.1.1 が搭載されており、`-proxy` オプションは利用できません。  
    この場合、プロキシ経由の接続を行うためには `proxytunnel` や `socat` などの代替ツールを検討してください。  
  バージョン確認例:
  ```bash
  openssl version
  openssl s_client -help | grep -i proxy
  ```

- **Bash シェル**  
  標準的な Bash シェルで動作します。

- **その他のユーティリティ**  
  `grep`, `sed`, `cut`, `mkdir` などの標準 Unix コマンド

## 設定
スクリプト内で以下の項目を変更可能です。

- **domains.txt**:  
  接続対象のドメインリスト。各行は `host:port` 形式で記述してください。

- **出力ディレクトリ**:  
  - `output/success`: SSL 証明書情報の保存先  
  - `output/error`: 接続エラー時の情報保存先

- **プロキシ設定**:  
  - `proxy_host`: プロキシサーバーのホスト名（例: `proxy.example.com`）
  - `proxy_port`: プロキシサーバーのポート番号（例: `8080`）  
  ※ 特定のホスト（例: `sub.example.com`）に対してのみプロキシ経由で接続するように設定しています。

## 使い方

1. **ファイルの配置**  
   - 本スクリプト（例: `script.sh`）と `domains.txt` を同一ディレクトリに配置してください。

2. **実行権限の付与**  
   ```bash
   chmod +x script.sh
   ```

3. **スクリプトの実行**  
   ```bash
   ./script.sh
   ```

4. **結果の確認**  
   - 接続成功時の証明書情報は `output/success/<host>.txt` に保存されます。  
   - 接続に失敗した場合はエラー情報が `output/error/<host>.txt` に保存され、画面上に赤色のメッセージが表示されます。

## 注意事項
- **プロキシ接続について**  
  OpenSSL の `-proxy` オプションは OpenSSL 3.x 以降で利用可能です。  
  Rocky Linux 9 などの環境であれば問題なく使用できますが、Rocky Linux 8 など古いバージョンでは利用できません。その場合、プロキシ経由接続を行うための別ツール（`proxytunnel` や `socat` など）の利用をご検討ください。

- **エラーハンドリング**  
  スクリプトは `set -euo pipefail` を使用せず、各処理毎にエラー状態を確認する実装となっています。これにより、個々の接続エラーが全体の処理停止につながらないように設計されています。

## ライセンス
このスクリプトは自由に利用および改変可能です。
