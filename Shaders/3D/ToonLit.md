# シェーダで設定できる色空間に関して

本シェーダでは基本的に Linear スペースで処理することを主目的として定めているため、設定できる色のプロパティは基本的に HDR 属性を持っています。

Unity では HDR 属性を持っていない色設定は基本的に sRGB として扱われ 1.0 / 2.2 の ガンマ補正が入る状態となっています。

これを回避することが主目的になるため、HDRの本来の目的である輝度情報の解像度を上げるということは [エミッション](#エミッション-emission) 以外はほとんど効力を発揮しない状態としています。

>HDR(High-dynamic-range)とは各色成分を保存できるビット幅がSDR(Standard-dynamic-range)時の 8 bit (0～255) よりも多くなっている状態を示します。  
`※各成分のビット量はプロジェクトの環境設定に依存します。`

# シェーダで扱う光に関する要素

本シェーダで出力される際に関連する要素には以下があります

- [間接光](#間接光-indirectlight)
- [直接光](#直接光-directlight)
- [オクルージョン](#オクルージョン-occlusion)
- [アルベド](#アルベド-albedo)
- [エミッション](#エミッション-emission)
- [フォグ](#フォグ-fog)

※ポストエフェクトが掛かっている場合には記載されていない要因が含まれる場合があります。[Frame Debugger](https://docs.unity3d.com/Manual/frame-debugger-window.html) や [Rendering Debugger](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@16.0/manual/features/rendering-debugger.html) でポストプロセスの影響下にあるかを確認するようにしてください。

## 間接光-IndirectLight

特定の光源からのものではなく、シーン全体に存在する光になります。

本シェーダでは加えて [Base/Shade Color](#baseshade-color) を [Overlay](https://ja.wikipedia.org/wiki/%E3%83%96%E3%83%AC%E3%83%B3%E3%83%89%E3%83%A2%E3%83%BC%E3%83%89#%E3%82%AA%E3%83%BC%E3%83%90%E3%83%BC%E3%83%AC%E3%82%A4%EF%BC%88Overlay%EF%BC%89) したものを間接光色として扱います。

本要素と[アルベド](#アルベド-albedo)を掛け合わせることで陰影の色となります。

その空間における最低限の明るさと色を決める役割があります。

Unity メニューの Window/Rendering/Lighting で開くことができる Lighting ウィンドウで設定できる要素になります。

本稿ではライトマップ(事前にシーンの明るさや色を計算してテクスチャとして扱う)に関しての説明は省きますが、こちらも間接光として扱います。

※Environment の Other Settings に関しては間接光ではなく後付けで処理される項目になります。

## 直接光-DirectLight

シーンに配置された Light コンポーネントで設定する光になります。

本要素と[アルベド](#アルベド-albedo)を掛け合わせることで反射色となります。

General/Mode が Realtime、あるいは Mix に設定されているコンポーネントを直接光として扱います。

Baked にされている Light はライトマップ生成時にのみ利用され、[間接光](#間接光-indirectlight)として扱われることになります。

また、ライトでは影を生成するかどうかも設定する必要があり、これは陰影の領域に影響を及ぼす場合があります。

## オクルージョン-Occlusion

遮蔽された空間に濃淡を付与し明るさを落とす効果になります。

通常は[間接光](#間接光-indirectlight)を扱う際にライトマップとして処理されますが、ここではポストエフェクトによるSSAO(スクリーンスペースアンビエントオクルージョン)として扱います。

ポストプロセスが有効であってもSSAOの効果を受けないようにする場合は [Transparent Surface](#transparent-surface) を有効にする必要があります。

## アルベド-Albedo

光を当てられた対象が物体表面で反射する光の割合を各成分ごとに表した情報になります。

[Base/Map](#basemap) と [Base/Color](#basecolor) が掛け合わされて求められます。

## エミッション-Emission

放出される光の割合を各成分ごとに表した情報になります。

物体そのものが生み出す光になるため、周囲の環境の影響を受けず加算されます。

[Emission/Map](#emissionmap) と [Emission/Color](#emissioncolor) が掛け合わされて求められます。

## フォグ-Fog

シーンの Lighting として設定されたフォグ情報は最終的に出力される色に対して線形で掛かります。

※ポストプロセスで設定されたフォグは本シェーダとは別のタイミングで施されます。

# 出力される色の領域

出力される色の領域は以下の種類があり、最終的にそれぞれの成分で最も大きい値が出力されます。

- [陰影](#陰影-shade)
- [拡散反射](#拡散反射-diffuse)
- [鏡面反射](#鏡面反射-specular)

※[エミッション](#エミッション-emission)と[フォグ](#フォグ-fog)は上記の領域区分とは無関係に処理されます。

## 陰影-Shade

[直接光](#直接光-directlight)が当たっていない、あるいは影を受けている箇所に[間接光](#間接光-indirectlight)が出力される部位を指します。

[Receive Shadows Off](#receive-shadows-off) を有効にしている場合には影を受けない状態となります。

## 拡散反射色-Diffuse

[直接光](#直接光-directlight)と[アルベド](#アルベド-albedo)が掛け合わされて求められ、陰影と判断されていない領域に反映されます。

領域の判定には以下のパラメータが参照されます。

- [Diffuse/Border](#diffuseborder)
- [Diffuse/Softness](#diffusesoftness)

## 鏡面反射-Specular

[直接光](#直接光-directlight)と[アルベド](#アルベド-albedo)が掛け合わされて求められ、陰影と判断されていない領域内に反映されます。

領域の判定には以下のパラメータが参照されます。

- [Specular/Border](#specularborder)
- [Specular/Softness](#specularsoftness)

鏡面反射は[拡散反射](#拡散反射-diffuse)に加算されます。
その際にどの程度加えるかは [Specular/Illuminance](#specularilluminance) で指定します。

# アウトラインのための環境設定

本シェーダで提供しているアウトラインが描画されるためには OutlineOnly の LightMode（ShaderTagId）がオブジェクトとして描画される必要があります。

| Renderer Feature | 提供 | 必須設定 |
| --- | --- | --- |
| Outline | 本パッケージ | 特になし |
| Render Objects | Universal Renderer Pipeline | Queue の設定<br>Layer Mask の設定<br>LightMode Tags に OutlineOnly を追加 |

# マテリアルパラメータ

以下は Inspector に表示されている各種パラメータの解説になります。

## Transparent Surface

有効にするとSSAO等の不透明オブジェクトのみに影響を及ぼす効果を受けない状態になります。

URP で定義されているキーワード [_SURFACE_TYPE_TRANSPARENT](keyword.md#_surface_type_transparent) が有効になり、バリアントが変わります。

## Receive Shadows Off

有効にすると影の影響を受けなくなります。

URP で定義されているキーワード [_RECEIVE_SHADOWS_OFF](keyword.md#_receive_shadows_off) が有効になり、バリアントが変わります

## Base/Map

[アルベド](#アルベド-albedo)のテクスチャを指定します。

## Base/Color

[アルベド](#アルベド-albedo)の色を指定します。

## Base/Shade Color

[間接光](#間接光-indirectlight)色を求めるために [Overlay](https://ja.wikipedia.org/wiki/%E3%83%96%E3%83%AC%E3%83%B3%E3%83%89%E3%83%A2%E3%83%BC%E3%83%89#%E3%82%AA%E3%83%BC%E3%83%90%E3%83%BC%E3%83%AC%E3%82%A4%EF%BC%88Overlay%EF%BC%89) するための色を指定します。

アルファ値はブレンド率として扱います。

## Normal (Option)

有効にすると法線に影響を与えるパラメータを編集できるようになります。

URP で定義されているキーワード `_NORMALMAP` が有効になり、バリアントが変わります

## Normal/Map

法線マップとなるテクスチャを指定します。

最終的な法線は頂点法線と Normal/Map、[Normal/Scale](#normalscale)から求められます。

## Normal/Scale

法線に掛けるスケール値を指定します。

最終的な法線は頂点法線と [Normal/Map](#normalmap)、Normal/Scale から求められます。

## Diffuse/Border

[拡散反射](#拡散反射-diffuse)の境界を指定します。

境界として扱うのはとライトベクトルと法線ベクトルの内積値です。

## Diffuse/Softness

[拡散反射](#拡散反射-diffuse)の境界を暈す割合を指定します。

## Specular/Border

[鏡面反射](#鏡面反射-specular)の境界を指定します。

境界として扱うのはライトと視線のハーフベクトルと法線ベクトルの内積値です。

## Specular/Softness

[鏡面反射](#鏡面反射-specular)の境界の境界を暈す割合を指定します。

## Specular/Illuminance

[鏡面反射](#鏡面反射-specular)を照らす割合を指定します。

## Specular/Volume Map

成分にそれぞれのパラメータを調整するマップです。

| 成分 | 調整項目 |
| --- | -------------------------------------------------- |
| R | [Specular/Border](#specularborder) に乗算 |
| G | [Specular/Softness](#specularsoftness) に乗算 |
| B | [Specular/Illuminance](#specularilluminance) に乗算 |
| A | 使用しません |


## Rimlight/Color

[アルベド](#アルベド-albedo)を主として、指定した色を [Overlay](https://ja.wikipedia.org/wiki/%E3%83%96%E3%83%AC%E3%83%B3%E3%83%89%E3%83%A2%E3%83%BC%E3%83%89#%E3%82%AA%E3%83%BC%E3%83%90%E3%83%BC%E3%83%AC%E3%82%A4%EF%BC%88Overlay%EF%BC%89) したモノがリムライトの色として使用されます。

アルファ値はブレンド率として扱います。

## Rimlight/Border

リムライトの境界を指定します。

境界として扱うのはライトと視線ベクトルと法線ベクトルの内積値です。

## Rimlight/Softness

リムライトの境界の境界を暈す割合を指定します。

## Rimlight/Illuminance

リムライトを照らす割合を指定します。

## Emission/Map

[エミッション](#エミッション-emission)のテクスチャを指定します。

## Emission/Color

[エミッション](#エミッション-emission)の色を指定します。

## Outline/Cull

アウトラインのカリングを指定します。

[Outline/Offset Depth](#Outline/Offset-Depth) を調整することで `Off` や `Back` でも運用できます。

## Outline/Color

アウトラインの色を指定します。

アルファ値は[アルベド](#アルベド-albedo)とのブレンド率を指定します。

## Outline/Direction

アウトラインとして拡張するメッシュの方向の求め方を指定します。

0 は頂点の法線方向に伸長し、1 は頂点カラーを法線として参照しその方向へ伸長します。

0～1 の間は上記のベクトルを線形補間した方向として扱われます。

頂点カラーを法線として扱う場合、事前にメッシュの頂点カラー成分に法線情報が書き込まれている必要があります。

本パッケージでは[メッシュの頂点カラー成分に法線を書き込むツール](#メッシュの頂点カラーに法線情報を書き込むツール)を提供していますのでそちらを利用ください。

## Outline/Width

アウトラインの幅を指定します。

## Outline/Offset Depth

深度を奥の方向にオフセットする量を指定します。

## Outline/Volume Map

アウトラインの幅と深度オフセットの値を調整するテクスチャを指定します。

| 成分  | 調整項目 |
| --- | ------------------------------------------------- |
| R   | [Outline/Width](#outlinewidth) に乗算 |
| G   | [Outline/Offset Depth](#outlineoffset-depth) に乗算 |
| B   | 使用しません |
| A   | 使用しません |

# メッシュの頂点カラーに法線情報を書き込むツール

本パッケージで提供しているのは、元のメッシュを元に別のメッシュを作成します。

作成されるメッシュアセットはメインアセットではなく、専用の設定アセットのサブアセットとして保持されます。

使用する場合は MeshFilter、あるいは SkinnedMeshRenderer に設定アセットのサブアセットにあるメッシュを割り当てる必要があります。

## 設定アセットの作成

専用の設定アセットを作成するには、プロジェクトウィンドウで以下の何れかのアセットを選択してください。
- MeshFilter を内包した Prefab、あるいは FBX
- Skinnded Mesh Renderer を内包した Prefab、あるいは FBX
- Mesh アセット

選択された状態でコンテキストメニューを開き `Create/Outline Mesh Baker` を選択することで設定アセットが作成されます。

作成されると同時にデフォルト設定でメッシュアセットがサブアセットに追加されます。

## 設定アセットの各種要素

Rename ボタンを押すと元のメッシュアセットの名前に準拠して設定アセットの名前を変更します。

Generate ボタンを押すことでサブアセットのメッシュを更新します。

メッシュを更新する際には以下の設定要素を参照します。

### Source

元のメッシュアセットが表示されています。

基本的には変更できませんが、元のアセットが削除された場合など、参照先を見失った場合は選択可能です。

ただし、基本的には参照先を削除した場合は設定アセットも削除してください。 

### Normal Bake Mode

メッシュの頂点カラーに書き込む値の算出モードを選択します

| モード | 概要 |
| --- | --- |
| Average | 同位置にある頂点の法線を全て合算した平均値を格納します |
| Normal Map | Normal Map で指定したテクスチャから得られた法線を格納します |
| Empty | 単位化された法線を格納します |
| Keep | 頂点カラーの値をそのまま保持します。<br>頂点カラーが存在しない場合は白が格納されます |

### Normal Map

[Normal Bake Mode](#normal-bake-mode) で Normal Map を指定した場合にのみ参照されます。

指定したテクスチャを法線マップとしてアクセスし、法線情報を頂点カラーに書き込みます。

## Width Bake Mode

頂点カラーのアルファ値にアウトラインの太さを格納します。

その際の太さを求めるモードを選択します。

| モード | 概要 |
| --- | --- |
| Width Map | Width Map で指定したテクスチャから得られたの赤成分を格納します |
| Vertex Color Red | 元の頂点カラーの赤成分を格納します |
| Vertex Color Green | 元の頂点カラーの緑成分を格納します |
| Vertex Color Blue | 元の頂点カラーの青成分を格納します |
| Vertex Color Alpha | 元の頂点カラーのアルファ成分を格納します |

## Distance Threshold

同じ位置にある頂点かどうかを判断する際に、誤差として扱う閾値を設定します。

0 以外の値にした場合、0 の時と比べてメッシュの生成に時間がかかる状態となります

## Shrink Tip Strength

先端を補足する度合の設定になります。