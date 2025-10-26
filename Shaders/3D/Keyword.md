# URPのシェーダのキーワード仕様

[Universal Render Pipeline環境でのシェーダー最適化対策 #Unity - Qiita](https://qiita.com/piti5/items/1f8d3bdfe5a64e478c7e)

## _RECEIVE_SHADOWS_OFF

キーワードが設定されている場合には影の影響を受けない

URP の Lit 系シェーダでは _ReceiveShadows が ０ の場合に BaseShaderGUI.cs でキーワードの設定解除が行われている

独自のシェーダで利用する場合は自前でキーワードの設定解除機構を作成する必要がある

## メインライトによる影に関する定義

以下はDirectional Light によって生成される影を扱うための定義になります

```
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
```

### _MAIN_LIGHT_SHADOWS

以下の条件をすべて満たす場合に Directional Light による影の影響を受ける

- _RECEIVE_SHADOWS_OFF が設定されていない

- URP Asset の Lighting/Main Light が Pre Pixel

- URP Asset の Shadows/Cascade Count が 1

- Directional Light の ShadowType が No Shadows 以外

キーワードは URP で設定されるため、自前で設定してはいけません

キーワードが設定されている場合に以下のキーワードが連動して定義される場合があります

- MAIN_LIGHT_CALCULATE_SHADOWS

- REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR

以下のキーワードとは排他関係にあります

- _RECEIVE_SHADOWS_OFF
- _MAIN_LIGHT_SHADOWS_CASCADE
- _MAIN_LIGHT_SHADOWS_SCREEN

### _MAIN_LIGHT_SHADOWS_CASCADE

以下の条件をすべて満たす場合に Directional Light による影の影響を受ける

- _RECEIVE_SHADOWS_OFF が設定されていない

- URP Asset の Lighting/Main Light が Pre Pixel

- URP Asset の Shadows/Cascade Count が 2 以上

- Directional Light の ShadowType が No Shadows 以外

キーワードは URP で設定されるため、自前で設定してはいけません

キーワードが設定されている場合に以下のキーワードが連動して定義される場合があります

- MAIN_LIGHT_CALCULATE_SHADOWS

以下のキーワードとは排他関係にあります

- _RECEIVE_SHADOWS_OFF
- _MAIN_LIGHT_SHADOWS_CASCADE
- _MAIN_LIGHT_SHADOWS_SCREEN

### _MAIN_LIGHT_SHADOWS_SCREEN

以下の条件をすべて満たす場合に Screen Space Shadows による影の影響を受ける

- URP Asset の Lighting/Main Light が Pre Pixel

- UR Data の Rendering/Rendering Path が Forward、または Forward+

- UR Data の Rendering/Renderer Features に Screen Space Shadow が追加されている

- RenderQueue が不透明描画(2000～2500)

- _RECEIVE_SHADOWS_OFF が設定されていない

- Directional Light の ShadowType が No Shadows 以外

キーワードは URP で設定されるため、自前で設定してはいけません

Screen Space Shadows は半透明描画には影響しません

以下のキーワードとは排他関係にあります。

- _RECEIVE_SHADOWS_OFF
- _MAIN_LIGHT_SHADOWS
- _MAIN_LIGHT_SHADOWS_CASCADE

## 追加ライトによる影に関する定義

以下は Point Light、または Spot Light によって生成される影を扱うための定義になります

```
#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
```

## _ADDITIONAL_LIGHTS

基本的にPoint Light、または Spot Light の ShadowType が No Shadows 以外の場合、且つ URP Asset の Lighting/Additional Lights を Pre Pixel の場合に追加ライトによる影響を受ける

UR Data の Rendering/Rendering Path が Forward+ の場合はキーワードとしては未定ではありますが、シェーダ内で 1 として定義されます。

UR Data の Rendering/Rendering Path が Deferred の場合、RenderQueue が不透明 (～2500)の場合は UniversalGBuffer パスが使用されるため未設定となりますが、半透明 ( 2501～) の場合には UniversalForward パスが使用されるため設定されます。

## _ADDITIONAL_LIGHTS_VERTEX

_ADDITIONAL_LIGHTS の条件にある URP Asset の Lighting/Additional Lights が Pre Vertex の場合に同条件で設定されます。

## ライティングの面調和関数に関する定義

```
#pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
```

### EVALUATE_SH_MIXED

URP Asset の Lighting/SH Evaluation Mode を Mixed にした上で UR Data の Rendering/Rendering Path を Forward、または Forward+ にした場合にライティングの面調和関数を頂点ごと、ピクセルごと両方を混合して評価ようになります。

### EVALUATE_SH_VERTEX

URP Asset の Lighting/SH Evaluation Mode を Pre Vertex にした上で UR Data の Rendering/Rendering Path を Forward、または Forward+ にした場合にライティングの面調和関数を頂点事に評価するようになります。

## LIGHTMAP_SHADOW_MIXING

```
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
```

 



### SHADOWS_SHADOWMASK

## _LIGHT_LAYERS

```
#pragma multi_compile _ _LIGHT_LAYERS 
```

## _FORWARD_PLUS

```
#pragma multi_compile _ _FORWARD_PLUS
```

# SRPのシェーダのキーワード仕様

### DIRLIGHTMAP_COMBINED

```
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
```



## LIGHT_MAP_ON

```
#pragma multi_compile _ LIGHTMAP_ON
```



### DYNAMICLIGHTMAP_ON

```
#pragma multi_compile _ DYNAMICLIGHTMAP_ON
```

### DEBUG_DISPLAY

```
#pragma multi_compile_fragment _ DEBUG_DISPLAY
```

### LOD_FADE_CROSSFADE

```
#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
```


