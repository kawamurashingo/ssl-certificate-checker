#!/bin/bash
# ※ set -euo pipefail は使用せず、各エラーは個別に処理しています

# ANSIカラーコード（緑と赤）
green='\e[32m'
red='\e[31m'
reset='\e[0m'

# 最大並列ジョブ数
max_jobs=5

# ドメイン一覧が記載されたファイル（各行は "host:port" 形式）
filename="domains.txt"

# 成功時とエラー時の出力ディレクトリ
success_dir="output/success"
error_dir="output/error"

# プロキシサーバーの設定（例）
proxy_host="proxy.example.com"
proxy_port=8080

# 出力ディレクトリが存在しない場合は作成
mkdir -p "$success_dir" "$error_dir"

# 各ドメインを処理する関数
process_domain() {
    local domain="$1"
    # 前後の空白を除去
    domain=$(echo "$domain" | xargs)
    # 空行はスキップ
    if [ -z "$domain" ]; then
        return
    fi

    # "host:port" 形式からホストとポートを抽出
    IFS=":" read -r host port <<EOF
$domain
EOF
    if [ -z "$host" ] || [ -z "$port" ]; then
        return
    fi

    local output_filename="${host}.txt"
    local proxy_option=""

    # 特定のホスト（例：sub.example.com）の場合はプロキシオプションを設定
    if [ "$host" = "sub.example.com" ]; then
        # OpenSSL 3.x以降では -proxy オプションが利用可能です。
        # 古いバージョンの場合は、proxytunnelなど別のツールの利用を検討してください。
        proxy_option="-proxy ${proxy_host}:${proxy_port}"
        echo "Connecting via proxy for: $host"
    fi

    # openssl s_client を用いて接続
    # -verify 0 により証明書検証を無効化し、標準入力を /dev/null にリダイレクトしています
    local output
    output=$(openssl s_client -connect "${host}:${port}" $proxy_option -verify 0 < /dev/null 2>&1)

    # 出力に証明書ブロックが含まれているかチェック
    echo "$output" | grep -q "-----BEGIN CERTIFICATE-----"
    if [ $? -ne 0 ]; then
        {
          echo "Connection error: ${host}:${port}"
          echo "Error reason: $(echo "$output" | head -n 1)"
        } > "${error_dir}/${output_filename}"
        echo -e "${red}Error output file saved: ${error_dir}/${output_filename}${reset}"
        return
    fi

    # 出力から最初の証明書ブロックを抽出
    local certificate
    certificate=$(echo "$output" | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p')

    # openssl x509 を使い、証明書の詳細情報を抽出
    local subject issuer dates not_before not_after
    subject=$(echo "$certificate" | openssl x509 -noout -subject 2>/dev/null)
    issuer=$(echo "$certificate" | openssl x509 -noout -issuer 2>/dev/null)
    dates=$(echo "$certificate" | openssl x509 -noout -dates 2>/dev/null)
    not_before=$(echo "$dates" | grep "notBefore=" | cut -d= -f2-)
    not_after=$(echo "$dates" | grep "notAfter=" | cut -d= -f2-)

    # 成功時の出力を保存
    {
      echo "Certificate information - ${host}:${port}"
      echo "Subject: ${subject}"
      echo "Issuer: ${issuer}"
      echo "Valid from: ${not_before}"
      echo "Valid until: ${not_after}"
    } > "${success_dir}/${output_filename}"

    echo -e "${green}Success output file saved: ${success_dir}/${output_filename}${reset}"
}

# ドメイン一覧ファイルが存在するかチェック
if [ ! -f "$filename" ]; then
    echo "ファイルが見つかりません: $filename"
    exit 1
fi

# 各ドメインを並列（最大 $max_jobs 同時）で処理
while IFS= read -r line || [ -n "$line" ]; do
    # 空行（または空白だけの行）はスキップ
    if [ -z "$(echo "$line" | xargs)" ]; then
        continue
    fi

    process_domain "$line" &

    # 現在のバックグラウンドジョブ数が max_jobs 以上なら待機
    while [ "$(jobs -r | wc -l)" -ge "$max_jobs" ]; do
        sleep 1
    done
done < "$filename"

# すべてのバックグラウンドジョブが終了するのを待機
wait
