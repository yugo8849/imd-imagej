# IMD Plugin - インストール トラブルシューティング

「Plugins or class not found」エラーが出る場合、以下の方法を順番に試してください。

---

## 🎯 方法1: 直接インストール（最も確実・推奨）

JARファイルを使わず、マクロファイルを直接配置する方法です。

### 手順

1. **古いプラグインを削除**
   - ImageJを終了
   - `plugins/` フォルダから `IMD_Plugin.jar` を削除

2. **Intensity_Modulated_Display.ijm をダウンロード**

3. **pluginsフォルダに配置**
   
   マクロファイルを以下のいずれかに配置：
   
   **オプションA: plugins/ 直下**
   ```
   ImageJ/
   └── plugins/
       └── Intensity_Modulated_Display.ijm  ← ここに配置
   ```
   
   **オプションB: plugins/Macros/ フォルダ**
   ```
   ImageJ/
   └── plugins/
       └── Macros/
           └── Intensity_Modulated_Display.ijm  ← ここに配置
   ```

4. **ImageJを再起動**

5. **確認**
   - **Plugins** メニューの下部に "Intensity Modulated Display" が表示されます
   - または **Plugins > Macros > Intensity Modulated Display**

### メリット
- ✅ 最も確実に動作する
- ✅ トラブルシューティングが簡単
- ✅ JARファイルの構造を気にしなくて良い

---

## 🎯 方法2: JARファイル v1（シンプル版）

**IMD_Plugin.jar** を使う方法です。

### JARファイルの構造
```
IMD_Plugin.jar
└── Intensity_Modulated_Display.ijm
```

### インストール手順
1. ImageJを終了
2. 古い `IMD_Plugin.jar` を削除
3. 新しい `IMD_Plugin.jar` を `plugins/` フォルダに配置
4. ImageJを再起動
5. **Plugins** メニューの下部を確認

---

## 🎯 方法3: JARファイル v2（macros版）

**IMD_Plugin_v2.jar** を使う方法です。

### JARファイルの構造
```
IMD_Plugin_v2.jar
└── macros/
    └── Intensity_Modulated_Display.ijm
```

### インストール手順
1. ImageJを終了
2. 古いプラグインを削除
3. `IMD_Plugin_v2.jar` を `plugins/` フォルダに配置
4. ImageJを再起動
5. **Plugins > Macros > Intensity Modulated Display** を確認

---

## 🔍 プラグインの場所を確認

インストール後、プラグインがどこに表示されるか確認してください：

### 表示される可能性のある場所
1. **Plugins** メニューの最下部
2. **Plugins > Macros** サブメニュー内
3. **Plugins > Analysis** サブメニュー内（方法により異なる）

### プラグイン名
- "Intensity Modulated Display"
- "Intensity_Modulated_Display"（アンダースコア付き）

**ヒント:** Pluginsメニューを開いて、スクロールしてすべての項目を確認してください。

---

## ✅ 動作確認

正しくインストールされると：

1. **Pluginsメニューに表示される**
   - メニュー項目が見つかる

2. **クリックすると実行される**
   - ダイアログが開く
   - エラーが出ない

3. **Log windowに表示される**
   - `Window > Log` で確認
   - "IMD Processing Started" などのメッセージ

---

## 🐛 それでもエラーが出る場合

### エラーメッセージを確認

1. **Window > Log** を開く
2. エラーメッセージをコピー
3. 具体的なエラー内容を確認

### よくあるエラーと対処法

#### "Plugins or class not found"
**原因:** JARファイルの構造が正しくない
**解決:** **方法1（直接インストール）** を試す

#### "File not found: IMD_Macro.ijm"
**原因:** ファイル名が一致しない
**解決:** ファイル名を確認（`Intensity_Modulated_Display.ijm` が正しい）

#### メニューに表示されない
**原因:** ImageJが再起動されていない
**解決:** ImageJを完全に終了して再起動

#### マクロは実行されるが、エラーが出る
**原因:** マクロ自体の問題
**解決:** Log windowでエラー内容を確認

---

## 📋 推奨インストール順序

1. **方法1（直接インストール）を試す** ← まずこれ！
   - 最も確実
   - トラブルが少ない

2. ダメなら **方法2（JARファイル v1）** を試す

3. それでもダメなら **方法3（JARファイル v2）** を試す

---

## 🔧 完全なクリーンインストール手順

すべてをリセットしてやり直す場合：

1. **ImageJを終了**

2. **すべての関連ファイルを削除**
   ```
   plugins/IMD_Plugin.jar              ← 削除
   plugins/IMD_Plugin_v2.jar           ← 削除
   plugins/Intensity_Modulated_Display.ijm  ← 削除
   plugins/Macros/Intensity_Modulated_Display.ijm  ← 削除
   IMD_parameters.txt                   ← 削除（オプション）
   ```

3. **ImageJを起動して確認**
   - IMD関連のメニュー項目がないことを確認

4. **ImageJを終了**

5. **方法1でインストール**
   - `Intensity_Modulated_Display.ijm` を `plugins/` に配置

6. **ImageJを起動**

7. **動作確認**

---

## 📦 ダウンロードファイル

### 推奨（方法1用）
- **Intensity_Modulated_Display.ijm** - マクロファイル単体

### 代替（方法2, 3用）
- **IMD_Plugin.jar** - シンプル版JARファイル
- **IMD_Plugin_v2.jar** - macros版JARファイル

---

## 💡 確実に動作する設定

以下の設定で確実に動作します：

```
ImageJ/
├── plugins/
│   └── Intensity_Modulated_Display.ijm  ← このファイル1つだけ
└── (その他のファイル)

起動後:
Plugins メニューの最下部に "Intensity Modulated Display" が表示される
```

---

## 🆘 まだ問題がある場合

以下の情報を提供してください：

1. ImageJ/Fijiのバージョン
2. OS（Windows/Mac/Linux）
3. インストール方法（1, 2, 3のどれを試したか）
4. エラーメッセージ（Window > Log の内容）
5. plugins/フォルダの内容（IMD関連ファイル）

---

**重要:** 古いプラグインファイルを削除してから、新しいファイルをインストールしてください！
