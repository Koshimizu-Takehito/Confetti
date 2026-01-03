# Confetti

[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKoshimizu-Takehito%2FConfetti%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Koshimizu-Takehito/Confetti) 
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FKoshimizu-Takehito%2FConfetti%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Koshimizu-Takehito/Confetti) 
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Koshimizu-Takehito/Confetti)

[🇺🇸 English](./README.md)

**Confetti** は、SwiftUI 向けの美しい紙吹雪アニメーションを提供する Swift パッケージです。

```swift
import ConfettiUI

struct ContentView: View {
    var body: some View {
        ConfettiScreen()
    }
}
```

## 特徴

- 🎉 美しい紙吹雪パーティクルアニメーション
- 🎨 カスタマイズ可能なカラーと設定プリセット
- ⚡ 固定タイムステップシミュレーションによる滑らかな 60/120Hz アニメーション
- ▶️ 動画プレイヤー風の制御（play, pause, resume, seek）
- 🧪 注入可能な乱数によるテスタブルなアーキテクチャ
- 📦 モジュラー設計（ConfettiCore / ConfettiPlayback / ConfettiUI）

## 目次

- [動作環境](#動作環境)
- [インストール](#インストール)
- [サンプルプロジェクト](#サンプルプロジェクト)
- [使い方](#使い方)
- [アーキテクチャ](#アーキテクチャ)
- [開発](#開発)
- [ライセンス](#ライセンス)

## 動作環境

- Swift 6.0+
- iOS 18.0+ / macOS 15.0+

---

## インストール

### Swift Package Manager

`Package.swift` に **Confetti** を追加します:

```swift
dependencies: [
    .package(url: "https://github.com/Koshimizu-Takehito/Confetti.git", from: "1.0.0")
]
```

ターゲットに依存を追加します:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "ConfettiUI", package: "Confetti")
    ]
)
```

### Xcode

1. File → Add Package Dependencies...
2. URL を入力: `https://github.com/Koshimizu-Takehito/Confetti.git`
3. バージョンを選択: `1.0.0` 以降

---

## サンプルプロジェクト

`Example/` ディレクトリに完全なサンプルアプリが含まれています。iOS と macOS の両方で動作し、さまざまな統合パターンを含む Confetti のすべての機能をデモンストレーションしています。

### サンプルの実行方法

```bash
# xed を使用
xed Example

# または make を使用
make open-example
```

Xcode でビルドして実行します。

### デモカテゴリ

サンプルアプリは3つのタブで構成されています：

#### Platform タブ

さまざまなレンダリング技術との統合をデモンストレーションします：

| デモ | 説明 |
|------|------|
| **@Observable** | モダンなマクロベースのオブザベーション（iOS 17+） |
| **ObservableObject** | Combine ベースのオブザベーション |
| **UIKit/AppKit** | Core Graphics 描画 |
| **SpriteKit** | シーングラフベースのスプライトレンダリング |
| **Metal** | インスタンス描画によるカスタム Metal シェーダー |

#### Basic タブ

このREADMEに記載されている基本的な使い方をカバーします：

| デモ | 説明 |
|------|------|
| **Minimal Usage** | 1行の ConfettiScreen |
| **Full Playback Controls** | 全コントロール付き ConfettiPlayerScreen |
| **Custom Trigger Button** | 独自のトリガー UI を構築 |
| **Button Style** | デフォルトボタンのカスタマイズ |
| **Configuration Presets** | celebration, subtle, explosion, snowfall |
| **Custom Configuration** | アニメーションパラメータの微調整 |

#### Advanced タブ

高度なカスタマイズパターンを探求します：

| デモ | 説明 |
|------|------|
| **Custom Colors** | ブランドカラーの統合 |
| **Config Presets Gallery** | インタラクティブなプリセット比較 |
| **Button Styles** | トリガーボタンのバリエーション |
| **Custom Triggers** | アイコン、FAB、タップ、長押し |
| **Design Tokens** | コンパクト、レギュラー、ラージサイズ |
| **Advanced Playback** | ConfettiCanvas による外部制御 |

---

## 使い方

### 基本的な使い方

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    var body: some View {
        ConfettiScreen()
    }
}
```

### カスタムトリガーボタン

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    var body: some View {
        ConfettiScreen { canvasSize, play in
            Button("お祝い！ 🎉") {
                play()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

### ボタンスタイルのカスタマイズ

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    var body: some View {
        ConfettiScreen()
            .confettiTriggerButtonStyle(.init(
                text: "パーティー！ 🎊",
                gradientColors: [.purple, .pink]
            ))
    }
}
```

### 設定プリセット

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    // 異なるエフェクトに異なるプリセットを使用
    @State private var player = ConfettiPlayer(configuration: .explosion)
    
    var body: some View {
        ConfettiScreen(player)
    }
}

// 利用可能なプリセット:
// - .celebration（デフォルト）- バランスの取れた華やかなエフェクト
// - .subtle                  - 穏やかでエレガント
// - .explosion               - 最大インパクト
// - .snowfall                - ゆっくり落下するエフェクト
```

### カスタム設定

ネストした設定構造体を通じて、アニメーションを細かく調整できます：

```swift
import ConfettiUI

var config = ConfettiConfig()

// ライフサイクル: パーティクル数、継続時間、フェードアウト
config.lifecycle.particleCount = 200
config.lifecycle.duration = 5.0
config.lifecycle.fadeOutDuration = 1.5

// 物理: 重力、抵抗、終端速度
config.physics.gravity = 1500
config.physics.drag = 0.92

// スポーン: 発生位置、速度、角度
config.spawn.originHeightRatio = 0.5
config.spawn.speedRange = 2000...4500

// 外観: サイズ、回転
config.appearance.baseSizeRange = 10...18
config.appearance.rotationXSpeedRange = 2.0...6.0

// 風: 力、変動
config.wind.forceRange = -100...100

let player = ConfettiPlayer(configuration: config)
```

### フル再生コントロール

`ConfettiPlayerScreen` を使用して、完全な動画プレイヤー風のエクスペリエンスを提供:

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    var body: some View {
        ConfettiPlayerScreenWithDefaultPlayer()
    }
}
```

### 高度な再生制御

外部制御の場合は、`ConfettiCanvas` を `onGeometryChange` と組み合わせて直接使用します:

```swift
import SwiftUI
import ConfettiUI

struct ContentView: View {
    @State private var player = ConfettiPlayer()
    @State private var canvasSize: CGSize = .zero

    var body: some View {
        VStack {
            ConfettiCanvas(renderStates: player.renderStates)
                .onGeometryChange(for: CGSize.self, of: \.size) { _, size in
                    canvasSize = size
                    player.updateCanvasSize(to: size)
                }

            HStack {
                Button("再生") { player.play(canvasSize: canvasSize) }
                Button("一時停止") { player.pause() }
                Button("再開") { player.resume() }
                Button("1秒へ") { player.seek(to: 1.0) }
                Button("停止") { player.stop() }
            }

            Text("時間: \(player.simulation.currentTime, specifier: "%.2f") / \(player.simulation.duration, specifier: "%.1f")秒")
        }
    }
}
```

### カスタムカラー

```swift
import ConfettiUI

struct BrandColorSource: ConfettiColorSource {
    let colors: [CGColor] = [
        CGColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1),
        CGColor(red: 0.8, green: 0.2, blue: 0.4, alpha: 1),
    ]
    
    mutating func nextColor(using numberGenerator: inout some RandomNumberGenerator) -> CGColor {
        colors.randomElement(using: &numberGenerator)!
    }
}

// 使用例
let player = ConfettiPlayer(colorSource: BrandColorSource())
```

### UIKit 連携

`ConfettiPlayer` とカスタム `UIView` で Core Graphics 描画を使用:

```swift
import ConfettiPlayback
import SwiftUI  // Color.cgColor に必要
import UIKit

class ConfettiView: UIView {
    private let player = ConfettiPlayer()
    private var displayLink: CADisplayLink?
    
    func play() {
        player.play(canvasSize: bounds.size)
        
        // VSync 同期更新のための DisplayLink を開始
        displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func handleDisplayLink() {
        guard player.simulation.state.isRunning else {
            displayLink?.invalidate()
            displayLink = nil
            return
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for state in player.renderStates {
            guard let cgColor = state.color.cgColor else { continue }
            
            context.saveGState()
            context.setAlpha(state.opacity)
            
            // 中心を軸に回転
            let center = CGPoint(x: state.rect.midX, y: state.rect.midY)
            context.translateBy(x: center.x, y: center.y)
            context.rotate(by: state.zRotation)
            context.translateBy(x: -center.x, y: -center.y)
            
            context.setFillColor(cgColor)
            context.fill(state.rect)
            context.restoreGState()
        }
    }
}
```

### AppKit 連携

同様に、カスタム `NSView` で Core Graphics 描画を使用:

```swift
import AppKit
import ConfettiPlayback
import SwiftUI  // Color.cgColor に必要

class ConfettiView: NSView {
    private let player = ConfettiPlayer()
    private var timer: Timer?
    
    override var isFlipped: Bool { true }
    
    func play() {
        player.play(canvasSize: bounds.size)
        
        // フレーム更新のためのタイマーを開始
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/120.0, repeats: true) { [weak self] _ in
            guard self?.player.simulation.state.isRunning == true else {
                self?.timer?.invalidate()
                return
            }
            self?.needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        for state in player.renderStates {
            guard let cgColor = state.color.cgColor else { continue }
            
            context.saveGState()
            context.setAlpha(state.opacity)
            
            let center = CGPoint(x: state.rect.midX, y: state.rect.midY)
            context.translateBy(x: center.x, y: center.y)
            context.rotate(by: state.zRotation)
            context.translateBy(x: -center.x, y: -center.y)
            
            context.setFillColor(cgColor)
            context.fill(state.rect)
            context.restoreGState()
        }
    }
}
```

---

## アーキテクチャ

Confetti はクリーンでテスタブルな3層アーキテクチャで設計されています:

```text
ConfettiUI
  - SwiftUIビュー / 画面コンポーネント / トリガーコンポーネント / デザイントークン
        │
        ▼
ConfettiPlayback
  - 再生制御 / フレーム駆動 / Render State変換 / カラーソース
        │
        ▼
ConfettiCore
  - ドメインモデル / 物理シミュレーション / 決定論的 & テスト容易
```

`ConfettiCore` は**内部モジュール**であり、ライブラリユーザーが直接アクセスすることはできません。
カスタムレンダリングには `ParticleRenderState` を提供する `ConfettiPlayback` を、SwiftUI ビューには `ConfettiUI` を使用してください。
`ConfettiConfig` や `ConfettiColorSource` などの主要な型は `ConfettiPlayback` 経由で再エクスポートされています。

### ConfettiCore（内部）

UI 非依存のドメインモデルと物理シミュレーション（実装詳細）:

- `ConfettiSimulation`: シミュレーションライフサイクルの状態機械（pause/resume/seek 対応）
- `ConfettoTraits`: 不変のパーティクル属性（サイズ、色、回転速度）
- `ConfettoState`: 可変のパーティクル状態（位置、速度、透明度）
- `ConfettiCloud`: 効率的なコンパクションを備えたパーティクルのコレクション
- `ConfettiConfig`: プリセット付きのシミュレーション設定（ConfettiPlayback 経由で再エクスポート）

### ConfettiPlayback

再生制御とレンダー状態管理:

- `ConfettiPlayer`: 動画プレイヤー風 API で紙吹雪の再生を制御
- `ConfettiConfig`: シミュレーション設定（プリセット付き、Core から再エクスポート）
- `ConfettiColorSource`: カスタムカラーパレット用プロトコル（Core から再エクスポート）
- `ConfettiRenderer`: バッファ再利用でドメイン状態をレンダー状態に変換
- `ParticleRenderState`: 描画可能なパーティクル表現
- `DefaultColorSource`: デフォルトの7色紙吹雪パレット
- `DisplayLinkDriver`: フレーム更新（iOS は CADisplayLink、macOS は 120Hz Timer）（内部）

### ConfettiUI

SwiftUI ビューとコンポーネント:

- `ConfettiScreen`: カスタマイズ可能なトリガー付きのプリセットビューコンポーネント
- `ConfettiPlayerScreen`: 再生コントロール付きのフル機能プレイヤー
- `ConfettiCanvas`: Canvas ベースのパーティクルレンダリング
- `ConfettiTriggerButton`: スタイル付きトリガーボタン
- `ConfettiDesignTokens`: UI コンポーネント用のカスタマイズ可能なデザインシステム

### 設計原則

- **固定タイムステップシミュレーション**: 60Hz と 120Hz ディスプレイでアニメーション速度が一定
- **決定論的シーク**: 任意の時刻にシークして一貫した結果を取得
- **注入可能な乱数**: 決定論的テストを可能に
- **関心の分離**: コアロジックは UI 非依存
- **再利用可能な再生制御**: `ConfettiPlayer` はカスタムビューと組み合わせて使用可能
- **バッファ再利用**: アニメーション中のアロケーションを最小化

---

## 開発

### 必要環境

- macOS 15.0+
- Xcode 16.0+（Swift 6.0+）
- [Mint](https://github.com/yonaskolb/Mint)（`make setup` 実行時に Homebrew があれば自動インストール）

### セットアップ

```bash
# リポジトリをクローン
git clone https://github.com/Koshimizu-Takehito/Confetti.git
cd Confetti

# 依存関係をインストール
make setup
```

### 利用可能なコマンド

| コマンド | 説明 |
|---------|------|
| `make setup` | Mint（必要な場合は自動インストール）と依存パッケージをインストール |
| `make sync` | 最新の変更を取得し、すべての依存関係を更新 |
| `make build` | パッケージをビルド |
| `make test` | テストを実行 |
| `make lint` | SwiftLint を実行 |
| `make lint-fix` | SwiftLint の自動修正を実行 |
| `make lint-strict` | SwiftLint を厳格モードで実行（警告をエラーとして扱う） |
| `make format` | SwiftFormat でコードを整形 |
| `make format-check` | コードフォーマットをチェック（CI 用） |
| `make fix` | コードの整形と自動修正を一括実行 |
| `make ci` | すべての CI チェックを実行 |
| `make open` | パッケージを Xcode で開く |
| `make open-example` | サンプルプロジェクトを Xcode で開く |
| `make clean` | ビルド成果物を削除 |
| `make help` | 利用可能なコマンドを表示 |

### PR を提出する前に

ローカルで CI チェックを実行して、変更が通ることを確認してください:

```bash
make ci
```

---

## ライセンス

Confetti は MIT ライセンスで提供されています。詳細は [LICENSE](LICENSE) ファイルを参照してください。
