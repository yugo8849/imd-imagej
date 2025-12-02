# IMD Plugin - アンインストール方法

## 🗑️ 基本的なアンインストール手順

### 方法1: 手動削除（推奨・最も確実）

1. **ImageJ/Fijiを終了**

2. **pluginsフォルダを開く**
   
   **Windows:**
   ```
   C:\Program Files\ImageJ\plugins\
   または
   C:\Fiji.app\plugins\
   ```
   
   **Mac:**
   ```
   /Applications/ImageJ.app/plugins/
   または
   /Applications/Fiji.app/plugins/
   ```
   アプリケーションを右クリック → "パッケージの内容を表示" → Contents/plugins/
   
   **Linux:**
   ```
   ~/ImageJ/plugins/
   または
   ~/Fiji.app/plugins/
   ```

3. **IMD_Plugin.jar を削除**
   - `IMD_Plugin.jar` を見つけて削除してください
   - ゴミ箱に移動または完全削除

4. **ImageJを起動**
   - プラグインがメニューから消えていることを確認

### 方法2: ImageJから削除（Fijiのみ）

Fijiの場合、Plugins Managerから削除できる場合があります：

1. **Help > Update...**
2. **Manage Update Sites** をクリック
3. インストールしたプラグインを見つける
4. アンインストール（ただし、手動インストールしたプラグインは表示されない場合があります）

**注意:** 手動でインストールしたJARファイルは、この方法では表示されないことが多いです。

## 🧹 完全なクリーンアップ（パラメータファイルも削除）

プラグインだけでなく、設定ファイルも削除したい場合：

1. **プラグインを削除**（上記の方法1）

2. **パラメータファイルを削除**
   
   **場所:**
   - Windows: `C:\Program Files\ImageJ\IMD_parameters.txt`
   - Mac: `/Applications/ImageJ.app/IMD_parameters.txt`
   - Linux: `~/ImageJ/IMD_parameters.txt`
   
   または、ImageJ内で確認：
   - **Edit > Options > Memory & Threads...**
   - ウィンドウ上部に表示されるパス + `IMD_parameters.txt`

3. **ImageJを起動**
   - すべてのIMD関連ファイルが削除されました

## 🔄 再インストールする場合

1. 古いプラグインを削除（上記の手順）
2. ImageJを再起動
3. 新しい `IMD_Plugin.jar` をインストール
4. ImageJを再起動

## 🔍 プラグインが見つからない場合

### pluginsフォルダ内を検索

**Windows（エクスプローラー）:**
```
pluginsフォルダで検索: IMD
```

**Mac（Finder）:**
```
Command + F で検索: IMD
```

**Linux（ターミナル）:**
```bash
cd ~/ImageJ/plugins
find . -name "*IMD*"
```

### すべてのJARファイルをリスト表示

**Windows（コマンドプロンプト）:**
```cmd
cd "C:\Program Files\ImageJ\plugins"
dir *.jar
```

**Mac/Linux（ターミナル）:**
```bash
cd ~/ImageJ/plugins
ls -la *.jar
```

## ⚠️ 注意事項

### 削除してはいけないファイル
- `ij.jar` - ImageJ本体（削除しないでください！）
- その他のシステムJARファイル

### 安全な削除方法
1. まずImageJを完全に終了
2. JARファイルをゴミ箱に移動（すぐに削除しない）
3. ImageJを起動して動作確認
4. 問題なければゴミ箱を空にする

## 🆘 トラブルシューティング

### 削除したのにメニューに残っている
- ImageJを完全に終了してから再起動してください
- タスクマネージャー（Windows）やアクティビティモニタ（Mac）でImageJプロセスが残っていないか確認

### pluginsフォルダが見つからない
ImageJ内で確認：
```
Edit > Options > Memory & Threads...
```
ウィンドウ上部に表示されるパスが ImageJ のインストールフォルダです。
そのフォルダ内の `plugins/` サブフォルダを探してください。

### 削除権限がない（Windows）
管理者権限が必要な場合があります：
1. エクスプローラーで JARファイルを右クリック
2. "管理者として実行" または "削除"
3. UACダイアログで "はい" をクリック

### Macで「パッケージの内容を表示」が見つからない
1. Finderでアプリケーションフォルダを開く
2. ImageJ.app または Fiji.app を右クリック
3. "パッケージの内容を表示" を選択
4. Contents/plugins/ に移動

## 📝 削除の確認方法

プラグインが正しく削除されたか確認：

1. ImageJを起動
2. **Plugins** メニューを開く
3. **Analysis** サブメニューを確認
4. "Intensity Modulated Display (IMD)" が表示されないことを確認

## 🔄 複数バージョンがインストールされている場合

異なる名前でインストールされている可能性があります：

```
plugins/
├── IMD_Plugin.jar          ← これを削除
├── IMD_Plugin_old.jar      ← これも削除
└── IMD_Plugin_backup.jar   ← これも削除
```

すべての IMD 関連 JAR ファイルを削除してください。

---

**アンインストール完了後は、ImageJを再起動することをお忘れなく！**
