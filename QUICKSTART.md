# IMD Plugin - クイックスタートガイド

## 🚀 最速インストール（3ステップ）

1. **IMD_Plugin.jar をダウンロード**
2. **ImageJ/Fiji で: Plugins > Install...**
3. **JARファイルを選択して、ImageJを再起動**

完了！ **Plugins > Analysis > Intensity Modulated Display (IMD)** から使えます。

## 📦 ダウンロードファイル

### すぐに使いたい方
- **IMD_Plugin.jar** - このファイル1つでOK！

### 開発者・カスタマイズしたい方
- **IMD-ImageJ-Plugin.zip** - 完全なソースコード、Maven設定、ドキュメント含む

## 🎯 初めての使い方（5分）

### 1. 画像を開く
```
ImageJ/Fiji で FRET画像とCFP画像を開きます
```

### 2. プラグインを実行
```
Plugins > Analysis > Intensity Modulated Display (IMD)
```

### 3. 画像を選択
ダイアログで：
- **FRET image**: FRET画像を選択
- **CFP (Donor) image**: CFP画像を選択

### 4. パラメータ設定（初回）
デフォルト値で試してみてください：
- Ratio max: 3
- Ratio min: -1
- Donor max: 6000
- Donor min: 0

Stack画像の場合：
- ☑ **Test mode** をチェック（最初のフレームのみ処理）

### 5. 実行
**OK** をクリック → 結果画像が表示されます

### 6. パラメータ調整（必要に応じて）
結果を見ながら：
1. Ratio range（色の範囲）を調整
2. Donor range（明るさの範囲）を調整
3. ☑ **Save parameters to file** をチェック
4. 再度実行

### 7. 全フレーム処理（Stackの場合）
1. Test mode のチェックを外す
2. 再度実行 → 全フレームが処理されます

## ⚙️ オプション機能

### バックグラウンド減算
```
☑ Subtract background (Rolling ball)
Rolling ball radius: 50
```
細胞サイズより大きい値を推奨

### Batch mode
```
☑ Use batch mode (hide intermediate images)
```
処理中の画像を非表示にして高速化

### パラメータ保存
```
☑ Save parameters to file
```
次回から同じ設定が自動的に読み込まれます

## 🔧 よくある質問

### Q: プラグインがメニューに表示されない
**A:** ImageJを再起動してください

### Q: パラメータが分からない
**A:** まずはデフォルト値で試してみてください。Stack画像の場合は**Test mode**をONにすると素早く調整できます

### Q: 結果が暗すぎる/明るすぎる
**A:** **Donor max/min** を調整してください。CFP画像のヒストグラム（Analyze > Histogram）を確認すると適切な範囲が分かります

### Q: 色の範囲が適切でない
**A:** **Ratio max/min** を調整してください

### Q: 処理に時間がかかる
**A:** 
1. ☑ **Batch mode** をONにする
2. Stack画像の場合、まず**Test mode**で最適なパラメータを見つける
3. その後、Test modeをOFFにして全フレーム処理

## 📚 詳細ドキュメント

もっと詳しく知りたい場合：
- **README_IMD.md**: 使い方の詳細、トラブルシューティング
- **INSTALLATION.md**: インストール方法の詳細、Update Site設定
- **CHANGELOG.md**: バージョン履歴

## 💡 推奨ワークフロー（Stack画像）

```
1. FRET & CFP の Stack 画像を開く
   ↓
2. IMD Plugin を実行
   ☑ Test mode ON
   ↓
3. パラメータ調整
   - Ratio max/min
   - Donor max/min
   - Rolling ball radius
   ↓
4. 結果を確認して満足したら
   ☑ Save parameters to file
   ↓
5. 再度実行
   ☐ Test mode OFF
   → 全フレーム処理完了！
```

## 🎓 パラメータの意味

### Ratio Range
- FRET/CFP の比率の表示範囲
- Physics LUTの色に対応
- 例: -1（青）～ 3（赤）

### Donor Range
- CFP輝度による明るさの規格化範囲
- 明るいCFPの領域は明るく、暗い領域は暗く表示
- CFPのヒストグラムから設定すると良い

### Rolling Ball Radius
- バックグラウンド減算の半径
- 細胞サイズより大きい値（通常50-100）
- 背景の不均一性を除去

## 🆘 サポート

問題がある場合：
1. **INSTALLATION.md** のトラブルシューティングを確認
2. Log window（Window > Log）でエラーメッセージを確認
3. GitHub Issues でサポートを受ける

## ✨ 次のステップ

1. ✅ プラグインをインストール
2. ✅ サンプル画像で試す
3. ✅ パラメータを最適化
4. ✅ 設定を保存
5. ✅ 本番データで使用
6. 🎉 論文に掲載！

---

**Happy Imaging! 🔬**
