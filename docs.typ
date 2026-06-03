#import "@preview/numbly:0.1.0": *
#import "@preview/octique:0.1.1": octique-inline

#let title = "ygo-definitions"
#let author = "arshtyi"
#let date = datetime.today()

#set document(title: title, author: author, date: date)

#let fonts = (
    cjk: "Noto Serif CJK SC",
    latin: "Times New Roman",
    chip: "JetBrains Mono",
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
#let linkto(url, icon: "link") = link(url, box(h(.25em) + octique-inline(color: blue.darken(40%), icon) + h(.25em)))
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
        font: fonts.chip,
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

= introduction

- 本项目ygo-definitions#linkto("https://github.com/arshtyi/ygo-definitions")是ygo-cards#linkto("https://github.com/arshtyi/ygo-cards")及其衍生项目链路（以下称为"本链路"）的数据定义说明。
- 所用到数据的原始定义主要见`ygopro-core/common.h`#linkto("https://github.com/Fluorohydride/ygopro-core/blob/master/common.h")，具体的字段码见`strings.conf`#linkto("https://github.com/mycard/ygopro-database/blob/master/locales/zh-CN/strings.conf")。
- 此链路专注于OCG、TCG、RD环境，不包括MD、Genesys环境。

= preliminaries

- 形式地，每张卡是一个JSON #json-type("object")，包含一些字段。
- 此链路中的所有字段都是卡面记述，且以简中YGOPro翻译为主。
- 一张卡不应当拥有的字段不被记录。
- 绝大多数字段若没有合法的值，此卡被跳过。

= ocg

本章针对于OCG、TCG。

== general

本节字段为所有卡拥有。

=== id

#json-property("id", "int")[
    一张卡的卡片密码，唯一确定这张卡。

    - 正式卡此字段的值（不含前导零）长度不超过$8$位。
    - 非正式卡此字段的值（含前导零）长度不低于$8$位。
    - 此字段的值在此链路中不显式包含前导零。
] <ot:id>

=== name

#json-property("name", "str")[
    一张卡的卡名。
] <ot:name>

=== attribute

#json-property("attribute", "int")[
    一张卡的属性。

    - 怪兽卡此字段的值为$[0,6]$的某整数，对应神·光·暗·风·地·炎·水。
    - 魔法卡此字段的值为$0$，对应魔法。
    - 陷阱卡此字段的值为$0$，对应陷阱。
] <ot:attribute>

=== image

#json-property("image", "int")[
    一张卡的中心图编号。

    - 此字段必须具有确定、可验证、符合的值。若无，值为$0$（因为此字段的非法值一般是上游造成的）。
    - 一般地，此字段的值对应此卡的官方中心图。
    - 对于衍生物，若没有对应的官方中心图，此字段的值将考虑退化到将此衍生物特殊召唤的卡的此字段的值。
] <ot:image>

=== description

#json-property("description", "str")[
    一张卡的描述。
] <ot:description>

=== alias

#json-property("alias", "int")[
    异画的原画@ot:id，值为$0$表明这是一张原画。
] <ot:alias>

=== type

#json-property("type", "array")[
    一张卡的类型，值为包含类型（#json-type("str")）的数组。

    - 怪兽卡此字段的值是`["怪兽", "种族", ...]`形式，其中"怪兽"近些年不再是卡面记述，但是为方便后续处理此处加上。
    - 魔法卡此字段的值是`["魔法", "类型"]`形式，虽然不是卡面记述，但是为方便后续处理此处加上。
    - 陷阱卡此字段的值是`["陷阱", "类型"]`形式，虽然不是卡面记述，但是为方便后续处理此处加上。
] <ot:type>

=== lf

#json-property("lf", "array")[
    一张卡的规制，值为包括OCG、TCG规制（值为可投入数量$[0,3]$，#json-type("int")）的数组。
] <ot:lf>

== monster

本节字段为怪兽卡专属。

=== atk

#json-property("atk", "int")[
    怪兽卡的攻击力，值为$[-1,+infinity)$的某整数。

    - $-1$表示卡面记述"？"。
] <ot:atk>

=== def

#json-property("def", "int")[
    非连接怪兽卡的守备力，值为$[-1,+infinity)$的某整数。

    - $-1$表示卡面记述"？"。
] <ot:def>

=== level

#json-property("level", "int")[
    非超量、连接怪兽卡的等级，值为$[0,13]$的某整数。
] <ot:level>

=== rank

#json-property("rank", "int")[
    超量怪兽卡的阶级，值为$[0,13]$的某整数。
] <ot:rank>

=== pendulumScale

#json-property("pendulumScale", "int")[
    灵摆怪兽卡的灵摆刻度，值为$[0,13]$的某整数。
] <ot:pendulumScale>

=== pendulumDescription

#json-property("pendulumDescription", "str")[
    灵摆怪兽的灵摆描述。
] <ot:pendulumDescription>

=== linkValue

#json-property("linkValue", "int")[
    连接怪兽卡的连接值，值为$[1,8]$的某整数。
] <ot:linkValue>

=== linkMarker

#json-property("maker", "array")[
    连接怪兽卡的连接标记，值为包含连接标记（#json-type("int")）的数组。以左上角（top-left）为起始，逆时针方向
    #align(center, table(
        columns: (10em, 8em),
        stroke: none,
        [location], $i$,
        table.hline(),
        [top-left], $0$,
        [left], $1$,
        [bottom-left], $2$,
        [bottom], $3$,
        [bottom-right], $4$,
        [right], $5$,
        [top-right], $6$,
        [top], $7$,
    ))
] <ot:linkMarker>

== under consideration

=== archetype

卡的字段（不是JSON字段）。此对整条链路并无太大作用。

= rd

本章针对于RD。

== general

本节字段为所有卡拥有。

=== legend

#json-property("legend", "bool")[
    一张卡是否为传说卡。
] <rd:legend>

=== id

#json-property("id", "int")[
    一张卡的卡片密码，唯一确定这张卡。

    - 正式卡此字段的值长度不低于$9$位。
] <rd:id>

=== name

#json-property("name", "str")[
    一张卡的卡名。
] <rd:name>

=== attribute

#json-property("attribute", "int")[
    一张卡的属性。

    - 怪兽卡此字段的值为$[0,5]$的某整数，对应光·暗·风·地·炎·水。
    - 魔法卡此字段的值为$0$，对应魔法。
    - 陷阱卡此字段的值为$0$，对应陷阱。
] <rd:attribute>

=== image

#json-property("image", "int")[
    一张卡的中心图编号。

    - 此字段必须具备确定、可验证、符合的值。若无，值为$0$（因为此字段的非法值一般是上游造成的）。
    - 一般地，此字段的值对应此卡的官方中心图。
] <rd:image>

=== type

#json-property("type", "array")[
    一张卡的类型，值为包含类型（#json-type("str")）的数组。

    - 怪兽卡此字段的值是`["怪兽", "种族", ...]`形式，其中"怪兽"不是卡面记述，但是为方便后续处理此处加上。
    - 魔法卡此字段的值是`["魔法", "类型"]`形式。
    - 陷阱卡此字段的值是`["陷阱", "类型"]`形式。
] <rd:type>

=== lf

#json-property("lf", "int")[
    一张卡的规制，值为$[0,3]$的某整数代表可投入数量。
] <rd:lf>

=== description

#json-property("description", "str")[
    一张卡的描述。
] <rd:description>

=== alias

#json-property("alias", "int")[
    异画的原画@rd:id，值为$0$表明这是一张原画。
] <rd:alias>

== monster

本节字段为怪兽卡专属。

=== atk

#json-property("atk", "int")[
    怪兽卡的攻击力，值为$[0,+infinity)$的某整数。
] <rd:atk>

=== def

#json-property("def", "int")[
    怪兽卡的守备力，值为$[0,+infinity)$的某整数。
] <rd:def>

=== level

#json-property("level", "int")[
    怪兽卡的等级，值为$[0,13]$的某整数。
] <rd:level>

=== maximum

#json-property("maximum", "int")[
    极大怪兽卡的位置，值为$[0,2]$的某整数，对应左·中·右。
] <rd:maximum>

=== maximumAtk

#json-property("maximumAtk", "int")[
    极大怪兽的极大攻击力，值为$[0,+infinity)$的某整数。
] <rd:maximumAtk>
