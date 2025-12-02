# Intensity Modulated Display (IMD) for ImageJ/Fiji

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![ImageJ](https://img.shields.io/badge/ImageJ-1.53c%2B-blue.svg)](https://imagej.net/)

FRET比率画像をCFP輝度で規格化した見やすいカラー表示に変換するImageJ/Fijiマクロです。

![IMD Example](https://via.placeholder.com/800x300/667eea/ffffff?text=IMD+Example+Image)
*Physics LUTによる見やすいカラー表示とCFP輝度による明るさの規格化*

## ✨ 主な機能

- 🎯 **簡単操作**: ダイアログで画像を選択するだけ
- ⚡ **高速**: Test modeで最初のフレームのみ処理してパラメータ調整
- 🎨 **美しい出力**: Physics LUTとCFP輝度規格化による見やすい表示
- 🔧 **多機能**: バックグラウンド減算、Batch mode、パラメータ保存
- 📊 **柔軟**: Stack画像/単一画像の両方に対応

## 🚀 クイックスタート

### インストール（3ステップ）

1. **[Intensity_Modulated_Display.ijm](https://github.com/yourusername/IMD-ImageJ/releases/latest/download/Intensity_Modulated_Display.ijm) をダウンロード**

2. **ImageJ/Fijiの `plugins/` フォルダに配置**
   - Windows: `C:\Program Files\ImageJ\plugins\`
   - Mac: `/Applications/ImageJ.app/plugins/`（パッケージの内容を表示）
   - Linux: `~/ImageJ/plugins/`

3. **ImageJを再起動**
   - **Plugins** メニューに "Intensity Modulated Display" が表示されます

### 使い方（5ステップ）

1. FRET画像とCFP画像をImageJで開く
2. **Plugins > Intensity Modulated Display** を実行
3. ダイアログで画像とパラメータを設定
4. Stack画像の場合は **Test mode** で素早くパラメータ調整
5. **OK** → 完成！

詳しくは [QUICKSTART.md](QUICKSTART.md) をご覧ください。

## 📋 動作環境

- **ImageJ**: 1.53c 以降
- **Fiji**: 対応
- **OS**: Windows, Mac, Linux
- **追加プラグイン**: 不要

## 📖 機能詳細

### Test Mode（パラメータ調整用）
Stack画像の最初のフレームのみを処理して、パラメータを素早く調整できます。
```
✓ Test mode ON → パラメータ調整 → 保存
✓ Test mode OFF → 全フレーム処理
```

### Background Subtraction
Rolling ballアルゴリズムによるバックグラウンド減算を自動実行。
```
Rolling ball radius: 50（細胞サイズより大きい値を推奨）
```

### Batch Mode
画像処理中の中間画像を非表示にして、高速化とちらつき防止。

### Parameter Persistence
パラメータは自動的に保存され、次回実行時に読み込まれます。
```
ImageJディレクトリ/IMD_parameters.txt
```

## 🎓 パラメータガイド

| パラメータ | 説明 | デフォルト値 | 調整のポイント |
|-----------|------|------------|--------------|
| Ratio max/min | FRET/CFP比率の表示範囲 | -1 ～ 3 | Ratio画像のヒストグラムを確認 |
| Donor max/min | CFP輝度の規格化範囲 | 0 ～ 6000 | CFP画像のヒストグラムを確認 |
| Rolling ball radius | バックグラウンド減算 | 50 | 細胞サイズより大きく |

## 📚 ドキュメント

- **[QUICKSTART.md](QUICKSTART.md)** - 5分で始めるガイド
- **[USER_GUIDE.md](USER_GUIDE.md)** - 詳細な使用方法
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - トラブルシューティング
- **[UNINSTALL.md](UNINSTALL.md)** - アンインストール方法
- **[CHANGELOG.md](CHANGELOG.md)** - 変更履歴

## 💡 使用例

### 基本的なワークフロー

```
1. FRET & CFP Stack画像を開く
2. Plugins > Intensity Modulated Display
3. ✓ Test mode ON でパラメータ調整
4. ✓ Save parameters で設定保存
5. ✓ Test mode OFF で全フレーム処理
```

### パラメータ調整のコツ

1. **Ratio range**: FRET/CFPの典型的な値の範囲に設定
2. **Donor range**: CFPのヒストグラムで輝度分布を確認
3. **Test mode**: 100フレームのStackでも数秒で結果確認

## 🔬 科学的背景

このマクロは、FRET（Förster Resonance Energy Transfer）イメージングにおいて、比率画像を見やすく表示するための手法です。

### 特徴
- **Physics LUT**: 比率値をカラーで表示（青→緑→黄→赤）
- **Intensity Modulation**: CFP輝度で明るさを規格化
- **利点**: 細胞内の局在と活性を同時に視覚化

## 📊 動作原理

```
1. FRET画像とCFP画像から比率を計算
2. 比率値をPhysics LUTで疑似カラー化
3. CFP輝度で明るさを規格化
4. RGB画像として出力
```

## 🤝 貢献

バグ報告、機能リクエスト、プルリクエストを歓迎します！

### 開発環境

```bash
# リポジトリのクローン
git clone https://github.com/yourusername/IMD-ImageJ.git

# マクロの編集
# ImageJのScript Editorで編集可能
```

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) をご覧ください。

## 📖 引用

研究でこのマクロを使用された場合は、以下のように引用してください：

```
Intensity Modulated Display (IMD) for ImageJ (2024)
GitHub: https://github.com/yourusername/IMD-ImageJ
```

## 🆘 サポート

- 💬 [GitHub Issues](https://github.com/yourusername/IMD-ImageJ/issues) で質問・バグ報告
- 📖 [Discussions](https://github.com/yourusername/IMD-ImageJ/discussions) でディスカッション
- 📧 Email: your.email@example.com

## ⭐ Star History

もしこのプロジェクトが役に立ったら、ぜひスターをお願いします！

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/IMD-ImageJ&type=Date)](https://star-history.com/#yourusername/IMD-ImageJ&Date)

## 🎉 更新履歴

### v1.0.0 (2024-11-06)
- 初回リリース
- ダイアログによる画像選択
- Test mode実装
- バックグラウンド減算
- パラメータ保存機能

詳細は [CHANGELOG.md](CHANGELOG.md) をご覧ください。

---

## 🌟 謝辞

- Developed with assistance from Claude (Anthropic)
- Based on the original IMD macro
- Thanks to all contributors and users

---

**Happy Imaging! 🔬**

*Version 1.0.0 - November 2024*
