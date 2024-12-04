import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/string
import stdin.{stdin}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.println
}

fn in() {
  stdin()
  |> iterator.index
  |> iterator.flat_map(fn(row) {
    let #(line, y) = row
    line
    |> string.to_graphemes
    |> iterator.from_list
    |> iterator.index
    |> iterator.map(fn(col) {
      let #(char, x) = col
      #(#(x, y), char)
    })
  })
  |> iterator.to_list
  |> dict.from_list
}

fn add(p1, p2) {
  let #(x1, y1) = p1
  let #(x2, y2) = p2
  #(x1 + x2, y1 + y2)
}

fn word(map, pos, dir, w) {
  case w {
    [] -> 1
    [hd, ..tail] -> {
      let np = add(pos, dir)
      let n = map |> dict.get(np)
      case n {
        Ok(c) if hd == c -> word(map, np, dir, tail)
        _ -> 0
      }
    }
  }
}

fn a() {
  let m = in()
  m
  |> dict.to_list
  |> list.fold(0, fn(acc, e) {
    let #(pos, char) = e
    let w = ["M", "A", "S"]
    case char {
      "X" ->
        acc
        + word(m, pos, #(1, 0), w)
        + word(m, pos, #(1, 1), w)
        + word(m, pos, #(0, 1), w)
        + word(m, pos, #(-1, 1), w)
        + word(m, pos, #(-1, 0), w)
        + word(m, pos, #(-1, -1), w)
        + word(m, pos, #(0, -1), w)
        + word(m, pos, #(1, -1), w)
      _ -> acc
    }
  })
  |> int.to_string
}

fn b() {
  let m = in()
  m
  |> dict.to_list
  |> list.fold(0, fn(acc, e) {
    let #(pos, char) = e
    case char {
      "A" ->
        acc
        + {
          word(m, pos, #(1, 1), ["S"])
          * word(m, pos, #(1, -1), ["S"])
          * word(m, pos, #(-1, 1), ["M"])
          * word(m, pos, #(-1, -1), ["M"])
        }
        + {
          word(m, pos, #(1, 1), ["M"])
          * word(m, pos, #(1, -1), ["M"])
          * word(m, pos, #(-1, 1), ["S"])
          * word(m, pos, #(-1, -1), ["S"])
        }
        + {
          word(m, pos, #(1, 1), ["M"])
          * word(m, pos, #(1, -1), ["S"])
          * word(m, pos, #(-1, 1), ["M"])
          * word(m, pos, #(-1, -1), ["S"])
        }
        + {
          word(m, pos, #(1, 1), ["S"])
          * word(m, pos, #(1, -1), ["M"])
          * word(m, pos, #(-1, 1), ["S"])
          * word(m, pos, #(-1, -1), ["M"])
        }
      _ -> acc
    }
  })
  |> int.to_string
}
