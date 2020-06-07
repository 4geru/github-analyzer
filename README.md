# github-analyzer

> My kickass Nuxt.js project

## Build Setup

```bash
# install dependencies
$ yarn install

# serve with hot reload at localhost:3000
$ yarn dev

# build for production and launch server
$ yarn build
$ yarn start

# generate static project
$ yarn generate
```

For detailed explanation on how things work, check out [Nuxt.js docs](https://nuxtjs.org).


## githubのPR/Commentを集約したCSVを作成する

Scriptはrubyで記述しているため、bundle installを行います

```bash
bundle install
cp .env.sample .env
```

必要な変数を指定します

```bash:.env
...
# https://github.com/settings/tokens へアクセスして Personal Access Token を取得する
# repo にチェックを付ける
GITHUB_API_KEY=''
# 対象となるリポジトリを指定する
# 
# example
# 4geru/github-analyzer
TARGET_REPOSITORY=''
```

以下のコマンドで `server/csv/pull_requests.csv`, `server/csv/comments.csv` が作成されます。

```bash
$ be ruby script/csv_generator.rb
1
2
...
```
