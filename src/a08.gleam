import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/set
import gleam/string
import gleam_community/maths/arithmetics
import stdin.{stdin}
import util.{unwrap}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> set.size
  |> int.to_string
  |> io.println
}

type Pos {
  Node(String)
  Free
}

fn in() {
  let l =
    stdin()
    |> iterator.index
    |> iterator.flat_map(fn(row) {
      let #(line, y) = row
      line
      |> string.to_graphemes
      |> iterator.from_list
      |> iterator.filter(fn(a) { a != "\n" })
      |> iterator.index
      |> iterator.map(fn(col) {
        let #(char, x) = col
        let f = case char {
          "." -> Free
          c -> Node(c)
        }
        #(#(x, y), f)
      })
    })
    |> iterator.to_list

  let max = l |> list.last |> unwrap |> pair.first
  let m =
    l
    |> list.filter(fn(f) {
      case f {
        #(_, Node(_)) -> True
        _ -> False
      }
    })
    |> list.group(by: pair.second)
    |> dict.map_values(fn(_k, v) { v |> list.map(pair.first) })
    |> dict.values
  #(m, max)
}

fn antinode(p) {
  let #(#(x1, y1), #(x2, y2)) = p
  let dx = x1 - x2
  let dy = y1 - y2
  [#(x1 + dx, y1 + dy), #(x2 - dx, y2 - dy)]
}

fn a() {
  let #(m, #(mx, my)) = in()
  m
  |> list.flat_map(fn(p) {
    p
    |> list.combination_pairs
    |> list.flat_map(antinode)
  })
  |> set.from_list
  |> set.filter(fn(p) {
    let #(x, y) = p
    x >= 0 && x <= mx && y >= 0 && y <= my
  })
}

fn min_step(a, b) {
  case arithmetics.gcd(a, b) {
    1 -> #(a, b)
    n -> min_step(a / n, b / n)
  }
}

fn min_pos(x, y, a, b, max) {
  let #(mx, my) = max
  let nx = x + a
  let ny = y + b
  case nx >= 0 && nx <= mx && ny >= 0 && ny <= my {
    True -> min_pos(nx, ny, a, b, max)
    False -> #(x, y)
  }
}

fn gen_pos(x, y, a, b, mx, my, acc) {
  let nx = x + a
  let ny = y + b
  case nx == mx && ny == my {
    True -> [#(x, y), #(mx, my), ..acc]
    False -> gen_pos(nx, ny, a, b, mx, my, [#(x, y), ..acc])
  }
}

fn antinode_b(p, max) {
  let #(#(x1, y1), #(x2, y2)) = p
  let #(dx, dy) = min_step(x1 - x2, y1 - y2)
  let #(min_x, min_y) = min_pos(x1, y1, -dx, -dy, max)
  let #(max_x, max_y) = min_pos(x1, y1, dx, dy, max)
  gen_pos(min_x, min_y, dx, dy, max_x, max_y, [])
}

fn b() {
  let #(m, max) = in()
  m
  |> list.flat_map(fn(p) {
    p
    |> list.combination_pairs
    |> list.flat_map(fn(p) { antinode_b(p, max) })
  })
  |> set.from_list
}
