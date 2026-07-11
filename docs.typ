#import "@preview/numbly:0.1.0": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let title = "ygo-definitions"
#let author = "arshtyi"
#let date = datetime.today()

#set document(title: title, author: author, date: date)

#let fonts = (
    cjk: "Noto Serif CJK SC",
    latin: "Lato",
    mono: "JetBrains Mono",
)
#set page(
    paper: "a4",
    numbering: "1",
    header: {
        set text(.9em)
        stack(
            spacing: .2em,
            grid(
                columns: (1fr,) * 2,
                align(left, context query(heading.where(level: 1))
                    .filter(h => h.location().page() <= here().page())
                    .last(default: none)
                    .body),
                align(right, title),
            ),
            v(.3em),
            line(length: 100%, stroke: 1pt + black),
            v(.15em),
            line(length: 100%, stroke: .5pt + black),
        )
        counter(footnote).update(0)
    },
)
#set text(
    font: (
        fonts.cjk,
        (name: fonts.latin, covers: "latin-in-cjk"),
    ),
    size: 11pt,
    lang: "zh",
    region: "cn",
)
#set par(justify: true, first-line-indent: 2em)
#set heading(numbering: numbly("{1:一}、", "{2:1}.", "{2}.{3:1}."))
#show heading.where(level: 1): it => {
    set align(center)
    show h.where(amount: .3em): none
    it
}
#set enum(numbering: numbly("{1:1}.", "{2:a}."))
#set list(indent: 6pt, marker: sym.bullet.tri)
#let palette = (
    int: (
        fill: rgb("#FEF0C7"),
        ink: rgb("#7A4E00"),
    ),
    bool: (
        fill: rgb("#DCEBFF"),
        ink: rgb("#124D96"),
    ),
    str: (
        fill: rgb("#DAF5E5"),
        ink: rgb("#146C43"),
    ),
    null: (
        fill: rgb("#ECEEF3"),
        ink: rgb("#4B5563"),
    ),
    array: (
        fill: rgb("#F2E5FF"),
        ink: rgb("#673C8E"),
    ),
    object: (
        fill: rgb("#DDF3F5"),
        ink: rgb("#155E63"),
    ),
    field: (
        fill: rgb("#FCE4EC"),
        ink: rgb("#8A274F"),
    ),
)
#let chip(label, style) = box(
    fill: style.fill,
    inset: (x: 0.38em, y: 0.12em),
    outset: (y: 0.20em),
    radius: 0.34em,
    text(
        font: fonts.mono,
        size: 0.86em,
        weight: "regular",
        fill: style.ink,
        label,
    ),
)
#let json-type(kind) = {
    let style = palette.at(kind, default: none)
    assert(style != none and kind != "field", message: "Unsupported JSON type: " + kind)
    chip(kind, style)
}
#let json-field(name) = {
    chip(name, palette.field)
}
#show figure.where(kind: "property"): set align(start)
#let json-property(name, kind, body) = figure(
    kind: "property",
    supplement: json-field(name),
    numbering: "1",
    outlined: true,
    block(
        width: 100%,
        breakable: true,
        {
            json-field(name)
            h(.3em)
            json-type(kind)
            [：#body]
        },
    ),
)
#show ref.where(form: "normal"): it => {
    let el = it.element
    if el != none and el.func() == figure and el.kind == "property" {
        link(el.location(), el.supplement)
    } else {
        it
    }
}
#show link: it => underline(offset: 3.5pt, stroke: 1.5pt, it)
#show raw: set text(font: (fonts.mono, fonts.cjk))
#show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: .3em, y: 0em),
    outset: (x: 0em, y: .3em),
    radius: .2em,
)

= introduction

- 本项目#link("https://github.com/arshtyi/ygo-definitions")[ygo-definitions]是#link("https://github.com/arshtyi/ygo-cards")[ygo-cards]的数据约定和掩码说明
- 仅包括OCG、TCG、Rush Duel环境，不包括Master Duel、Genesys环境
- 每张卡是一个包含若干属性的JSON #json-type("object")

= ot

#let masks = json("assets/ot-field-mappings.json")
#let hash = read("assets/ot-field-mappings.json.sha256sum").slice(0, 64)
#figure(
    table(
        columns: 2,
        [hash], hash,
    ),
    caption: [OCG & TCG Hash],
)

== general

=== id

#json-property("id", "int")[
    一张卡的卡片密码，唯一确定这张卡，长度不超过$8$位
] <ot:id>

=== name

#json-property("name", "str")[
    一张卡的卡名
] <ot:name>

=== attribute

#json-property("attribute", "int")[
    一张卡的属性

    - 怪兽的值为$[0,6]$的某整数，对应怪兽的神·光·暗·风·地·炎·水属性
    - 魔法的值为$0$，对应魔法属性
    - 陷阱的值为$0$，对应陷阱属性

    #figure(
        table(
            columns: masks.attributeCodes.len() + 1,
            [掩码], ..masks.attributeCodes.map(attribute => attribute.rawCode),
            [值], ..masks.attributeCodes.map(attribute => attribute.outputValue).map(str)
        ),
        caption: [OCG & TCG Attribute],
    )
] <ot:attribute>

=== image

#json-property("image", "int")[
    一张卡的中心图编号

    - 确定、可验证、符合的中心图编号。若无，值为$0$
    - 一般地，值对应此卡的官方中心图
] <ot:image>

=== description

#json-property("description", "str")[
    一张卡的描述文本
] <ot:description>

=== alias

#json-property("alias", "int")[
    异画的原画@ot:id，值为$0$表明这是一张原画
] <ot:alias>

=== type

#json-property("type", "array")[
    一张卡的类型，值为具体类型（#json-type("str")）的数组```json ["primary type", "subtype"]```

    #figure(
        table(
            columns: masks.primaryTypeFlags.len() + 1,
            [掩码], ..masks.primaryTypeFlags.map(type => type.mask),
            [值], ..masks.primaryTypeFlags.map(type => type.outputName),
        ),
        caption: [OCG & TCG Primary Type],
    )
    #figure(
        {
            let chunk-size = 6
            table(
                columns: chunk-size + 1,
                ..{
                    let cells = ()
                    for chunk in masks.subtypeFlags.rev().chunks(chunk-size) {
                        let padding = chunk-size - chunk.len()
                        cells += ([掩码],) + chunk.map(type => type.mask) + ([],) * padding
                        cells += ([值],) + chunk.map(type => type.outputName) + ([],) * padding
                    }
                    cells
                }
            )
        },
        caption: [OCG & TCG Card Subtype],
    )
    #figure(
        {
            let chunk-size = 7
            table(
                columns: chunk-size + 1,
                ..{
                    let cells = ()
                    for chunk in masks.raceCodes.chunks(chunk-size) {
                        let padding = chunk-size - chunk.len()
                        cells += ([掩码],) + chunk.map(type => type.rawCode) + ([],) * padding
                        cells += ([值],) + chunk.map(type => type.outputName) + ([],) * padding
                    }
                    cells
                }
            )
        },
        caption: [OCG & TCG Race],
    )
    为兼容上游数据，需对一些类型作合法性推断
    #figure(
        table(
            columns: 2,
            [掩码], masks.inferredMonsterTypeMask,
        ),
        caption: [OCG & TCG Inferred Monster Type],
    )
] <ot:type>

=== lf

#json-property("lf", "array")[
    一张卡的禁限，值为OCG、TCG可投入数量($[0,3]$，#json-type("int")）的数组```json [ocg, tcg]```
] <ot:lf>

== monster

=== atk

#json-property("atk", "int")[
    怪兽的攻击力，值为$[-1,+infinity)$的某整数
] <ot:atk>

=== def

#json-property("def", "int")[
    怪兽的守备力，值为$[-1,+infinity)$的某整数
] <ot:def>

=== level

#json-property("level", "int")[
    怪兽的等级，值为$[0,13]$的某整数
] <ot:level>

=== rank

#json-property("rank", "int")[
    怪兽的阶级，值为$[0,13]$的某整数
] <ot:rank>

=== pendulumScale

#json-property("pendulumScale", "int")[
    怪兽的灵摆刻度，值为$[0,13]$的某整数
] <ot:pendulumScale>

=== pendulumDescription

#json-property("pendulumDescription", "str")[
    怪兽的灵摆描述文本
] <ot:pendulumDescription>

=== linkValue

#json-property("linkValue", "int")[
    怪兽的连接值，值为$[1,8]$的某整数
] <ot:linkValue>

=== linkMarker

#json-property("marker", "array")[
    怪兽的连接标记，值为包含连接标记（#json-type("int")）的数组。
    #figure(
        table(
            columns: masks.linkMarkerFlags.len() + 1,
            [掩码], ..masks.linkMarkerFlags.map(type => type.mask),
            [值], ..masks.linkMarkerFlags.map(type => type.outputPosition).map(str)
        ),
        caption: [OCG & TCG Link Marker],
    )
] <ot:linkMarker>

= rd

#let masks = json("assets/rd-field-mappings.json")
#let hash = read("assets/rd-field-mappings.json.sha256sum").slice(0, 64)
#figure(
    table(
        columns: 2,
        [hash], hash,
    ),
    caption: [Rush Duel Hash],
)

== general

=== legend

#json-property("legend", "bool")[
    一张卡是否为传说卡

    #figure(
        table(
            columns: 2,
            [掩码], masks.legendTypeMask,
            [值], [1],
        ),
        caption: [Rush Duel Legend Type],
    )
] <rd:legend>

=== id

#json-property("id", "int")[
    一张卡的卡片密码，唯一确定这张卡
] <rd:id>

=== name

#json-property("name", "str")[
    一张卡的卡名
] <rd:name>

=== attribute

#json-property("attribute", "int")[
    一张卡的属性

    - 怪兽的值为$[0,5]$的某整数，对应怪兽的光·暗·风·地·炎·水属性
    - 魔法的值为$0$，对应魔法属性
    - 陷阱的值为$0$，对应陷阱属性

    #figure(
        table(
            columns: masks.attributeCodes.len() + 1,
            [掩码], ..masks.attributeCodes.map(attribute => attribute.rawCode),
            [值], ..masks.attributeCodes.map(attribute => attribute.outputValue).map(str)
        ),
        caption: [Rush Duel Attribute],
    )
] <rd:attribute>

=== image

#json-property("image", "int")[
    一张卡的中心图编号

    - 确定、可验证、符合的值。若无，值为$0$
    - 一般地，值对应此卡的官方中心图
] <rd:image>

=== type

#json-property("type", "array")[
    一张卡的类型，值为具体类型（#json-type("str")）的数组```json ["primary type", "subtype"]```

    #figure(
        table(
            columns: masks.primaryTypeFlags.len() + 1,
            [掩码], ..masks.primaryTypeFlags.map(type => type.mask),
            [值], ..masks.primaryTypeFlags.map(type => type.outputName),
        ),
        caption: [Rush Duel Primary Type],
    )
    #figure(
        table(
            columns: masks.subtypeFlags.len() + 1,
            [掩码], ..masks.subtypeFlags.rev().map(type => type.mask),
            [值], ..masks.subtypeFlags.rev().map(type => type.outputName),
        ),
        caption: [Rush Duel Subtype],
    )
    #figure(
        {
            let chunk-size = 5
            table(
                columns: chunk-size + 1,
                ..{
                    let cells = ()
                    for chunk in masks.raceCodes.chunks(chunk-size) {
                        let padding = chunk-size - chunk.len()
                        cells += ([掩码],) + chunk.map(type => type.rawCode) + ([],) * padding
                        cells += ([值],) + chunk.map(type => type.outputName) + ([],) * padding
                    }
                    cells
                }
            )
        },
        caption: [Rush Duel Race],
    )

    为兼容仪式怪兽，需对仪式怪兽进行融合怪兽掩码处理
    #figure(
        table(
            columns: 3,
            [掩码], masks.fusionTypeMask, masks.ritualTypeMask,
            [说明], [融合怪兽], [仪式怪兽],
        ),
        caption: [Rush Duel Fusion & Ritual],
    )
] <rd:type>

=== lf

#json-property("lf", "int")[
    一张卡的禁限，值为$[0,3]$的某整数代表可投入数量
] <rd:lf>

=== description

#json-property("description", "str")[
    一张卡的描述文本
] <rd:description>

=== alias

#json-property("alias", "int")[
    异画的原画@rd:id，值为$0$表明这是一张原画
] <rd:alias>

== monster

=== atk

#json-property("atk", "int")[
    怪兽的攻击力，值为$[0,+infinity)$的某整数
] <rd:atk>

=== def

#json-property("def", "int")[
    怪兽的守备力，值为$[0,+infinity)$的某整数
] <rd:def>

=== level

#json-property("level", "int")[
    怪兽的等级，值为$[0,13]$的某整数
] <rd:level>

=== maximum

#json-property("maximum", "int")[
    极大怪兽的位置，值为$[0,2]$的某整数，对应左·中·右
    #figure(
        table(
            columns: masks.maximumPositionMarkers.len() + 1,
            [标记], ..masks.maximumPositionMarkers.map(type => type.markers.join("/")),
            [值], ..masks.maximumPositionMarkers.map(type => type.position).map(str)
        ),
        caption: [Rush Duel Card Maximum Marker],
    )
] <rd:maximum>

=== maximumAtk

#json-property("maximumAtk", "int")[
    怪兽的极大攻击力，值为$[0,+infinity)$的某整数
] <rd:maximumAtk>
