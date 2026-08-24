#import "@preview/fletcher:0.5.8": *

#let v-space = v(2em, weak: true)

#let demo(..args) = [
  #args.at(0)
  Translated:
  #args.at(1)
  #text(0.8em, luma(120))[
    The above is for demonstrational purposes only.
  ]
]

#let embed_code(path, lang) = {
  let data = read(path)
  [
    == File: #" " #raw(path.replace("../", "")) #label(path.replace("../", ""))
    #raw(data, lang: lang, block: true)
  ]
}

#let div = line(length: 100%, stroke: rgb(200, 200, 200))

#let code(..args) = if "両方" in 設定 and 設定.両方 {
  demo(..args)
} else {
  context args.at(int(not (日本語())))
}

#let shunting-yard(prelude: bool, diagrams: array) = {
  let args = (inset: 1em, corner-radius: 0.25em, width: 9em)
  let depth = 0
  let res = ()

  for state in diagrams {
    let tokens-label = label("tok" + str(depth))
    let op-label = label("op" + str(depth))
    let res-label = label("res" + str(depth))
    let op-enclosing-label = label("op-label" + str(depth))
    let res-enclosing-label = label("res-label" + str(depth))

    res.push((
      node((0, depth), [#state.at(1)], ..args, name: op-label),
      node((1, depth), [#state.at(0)], ..args, name: tokens-label),
      if state.at(3) != none {
        let (from, to) = state.at(3).map(a => label(a + str(depth)))
        edge(from, to, "-|>")
      },
      node((2, depth), [#state.at(2)], ..args, name: res-label),

      ..if depth == 0 and prelude {
        (
          node(
            enclose: (op-label,),
            ..args,
            shape: shapes.bracket.with(dir: right, label: [Operator\ stack], sep: -0.5em),
            name: op-enclosing-label,
          ),
          node(
            enclose: (res-label,),
            ..args,
            shape: shapes.bracket.with(dir: left, label: [Result\ queue], sep: -0.5em),
            name: res-enclosing-label,
          ),
        )
      },

      node(
        enclose: (
          tokens-label,
          op-label,
          res-label,
          ..if depth == 0 and prelude { (op-enclosing-label, res-enclosing-label) },
        ),
        corner-radius: 0.25em,
        width: 15em,
        height: if depth == 0 { 7em } else { 4em },
        name: label("state" + str(depth)),
        label: if depth == 0 { align(top, diagrams.at(depth).at(4)) },
        shape: shapes.rect,
      ),
    ))

    if depth + 1 < diagrams.len() {
      res.push(edge(
        label("state" + str(depth)),
        label("state" + str(depth + 1)),
        "--|>",
        label: align(top, diagrams.at(depth + 1).at(4)),
        label-anchor: "center",
      ))
    }

    depth += 1
  }

  align(center)[
    #set text(size: 10pt)
    #diagram(node-stroke: .1em, spacing: 4em, ..res)
  ]
}
