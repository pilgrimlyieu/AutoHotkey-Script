; Only support bold, italic, mark, image, url syntax

global Tags := [
    ["<i>", "</i>"],
    ["<b>", "</b>"],
    ["<b><i>", "</i></b>"],
]

simpleMDtoHTML(content) {
    return ImageandUrl(Tag(content))
}

simpleHTMLtoMD(content) {
    content := RegExReplace(content, "</?b>", "**")
    content := RegExReplace(content, "</?i>", "*")
    content := RegExReplace(content, "</?mark>", "==")
    return content
}

ImageandUrl(content, on := 1) {
    if on {
        content := RegExReplace(content, "!\[(.+?)\]\((.+?)\)", "<img src='$2' alt='$1'>")
        content := RegExReplace(content, "\[(.+?)\]\((.+?)\)", "<a href='$2'>$1</a>")
        content := RegExReplace(content, "[\n\r]+", "<br>`n")
    }
    return content
}

Tag(content) {
    layers     := []
    tag_level  := 0
    mark_level := 0
    line_break := 0
    mark_pair  := 0
    result     := ""
    loop parse content {
        try
            layer := layers[layers.Length]
        catch Error
            layer := ""
        if (A_LoopField == "=" && (mark_level == 1 || (mark_level == 0 && SubStr(content, A_Index - 1, 1) != "\")))
            mark_level += 1
        else if (A_LoopField == "*" && (!layer || tag_level < layer) && (tag_level > 0 || SubStr(content, A_Index - 1, 1) != "\"))
            tag_level += 1
        else {
            if (mark_level > 0) {
                if (mark_level == 2) {
                    result .= mark_pair ? "</mark>" : "<mark>"
                    mark_pair := !mark_pair
                }
                else
                    result .= "="
                mark_level := 0
            }

            if (!layer || (0 < tag_level && tag_level < layer)) {
                layers.Push(tag_level)
                try
                    result .= Tags[tag_level][1]
                tag_level := 0
            }
            else if (tag_level == layer) {
                layers.Pop()
                result .= Tags[tag_level][2]
                tag_level := 0
            }

            if (A_LoopField == "`n") {
                if (line_break = 0) {
                    line_break := 1
                    result .= "<br>`n"
                }
                layers := []
                mark_pair := 0
            }
            else
                line_break := 0

            if (A_LoopField == "=" && (mark_level == 1 || (mark_level == 0 && SubStr(content, A_Index - 1, 1) != "\")))
                mark_level += 1
            else if (A_LoopField == "*" && (!layer || tag_level < layer) && (tag_level > 0 || SubStr(content, A_Index - 1, 1) != "\"))
                tag_level += 1
            else
                result .= (A_LoopField != "`n") ? A_LoopField : ""
        }
    }
    return result
}

; test {{{1
md2html_test := "
(
**这个**很*重要*，尤其是***这个***。

如果**不是***这个*，何以==至此==？

\*避免匹配=这些\*\*，\==

测试=啊=打发十分=发生=

以下四项不推荐

1. 还有==这个====这个==

2. 还有*这个**这个*

3. 还有**这个****这个**

4. 还有***这个******这个***



长断行

混用==**这样**==，==以及***这样**的方法*呀*呼呼**哈哈***如何==

单行结束==匹配标签，即**标签不跨行*一*

单行结束==匹配标签，即**标签不跨行

![图片](a.jpg)
[内容](lianjie.com)
)"

; MsgBox simpleMDtoHTML(md2html_test)
; }}}1
