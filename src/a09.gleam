import argv
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/string
import stdin.{stdin}
import util.{parse}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.println
}

type Block {
  Free
  File(Int)
}

fn in() {
  let #(_, _, l) =
    stdin()
    |> iterator.to_list
    |> string.join("")
    |> string.trim
    |> string.to_graphemes
    |> list.map(parse)
    |> list.fold(#(Free, 0, []), fn(acc, c) {
      let #(prev, id, a) = acc
      let #(next, next_id) = case prev {
        Free -> #(File(id), id)
        File(_) -> #(Free, id + 1)
      }
      let l =
        iterator.repeatedly(fn() { next })
        |> iterator.take(c)
        |> iterator.to_list
      #(next, next_id, [l, ..a])
    })
  l
  |> list.flatten
  |> list.reverse
  |> iterator.from_list
  |> iterator.index
  |> iterator.to_list
}

fn defrag(forward, backward, acc) {
  case backward {
    [#(File(b), bid), ..bt] ->
      case forward {
        [] -> acc |> list.reverse
        [#(_, fid), ..] if fid > bid -> acc |> list.reverse
        [#(Free, _), ..tail] -> {
          defrag(tail, bt, [b, ..acc])
        }
        [#(File(b), _), ..tail] -> {
          defrag(tail, backward, [b, ..acc])
        }
      }
    _ -> panic
  }
}

fn a() {
  let l = in()
  let r =
    list.reverse(l)
    |> list.filter(fn(e) {
      case e {
        #(Free, _) -> False
        _ -> True
      }
    })
  defrag(l, r, [])
  |> list.index_fold(0, fn(acc, i, index) { i * index + acc })
  |> int.to_string
}

type Space {
  Empty(Int)
  Full(Int, Int)
}

fn merge_space(l) {
  case l {
    [] -> []
    [Empty(0), ..t] -> merge_space(t)
    [Empty(a), Empty(b), ..t] -> merge_space([Empty(a + b), ..t])
    [e, ..t] -> [e, ..merge_space(t)]
  }
}

fn remove(l, e) {
  let assert Full(_, id) = e
  case l {
    [] -> []
    [Full(c, i), ..t] if i == id -> [Empty(c), ..remove(t, e)]
    [q, ..t] -> [q, ..remove(t, e)]
  }
}

fn replace_first(l, elem, acc) {
  let assert Full(c, _) = elem
  case l {
    [Empty(n), ..t] if n >= c ->
      [t |> remove(elem) |> list.reverse, [Empty(n - c), elem, ..acc]]
      |> list.flatten
      |> merge_space
      |> list.reverse
    [Empty(n), ..t] -> replace_first(t, elem, [Empty(n), ..acc])
    [f, ..] if f == elem ->
      [l |> list.reverse, acc] |> list.flatten |> list.reverse
    [f, ..t] -> replace_first(t, elem, [f, ..acc])
    [] -> acc |> list.reverse
  }
}

fn defrag_b(forward, backward) {
  case backward {
    [Full(c, id), ..t] -> {
      let f = forward |> replace_first(Full(c, id), [])
      defrag_b(f, t)
    }
    [Empty(_), ..t] -> defrag_b(forward, t)
    [] -> forward
  }
}

fn b() {
  let #(_, _, r) =
    stdin()
    |> iterator.to_list
    |> string.join("")
    |> string.trim
    |> string.to_graphemes
    |> list.map(parse)
    |> list.fold(#(False, 0, []), fn(acc, c) {
      let #(prev, id, a) = acc
      let #(l, next_id) = case prev {
        False -> #(Full(c, id), id + 1)
        True -> #(Empty(c), id)
      }
      #(!prev, next_id, [l, ..a])
    })
  let f = list.reverse(r)
  defrag_b(f, r)
  |> list.flat_map(fn(b) {
    case b {
      Empty(n) -> iterator.repeatedly(fn() { 0 }) |> iterator.take(n)
      Full(n, j) -> iterator.repeatedly(fn() { j }) |> iterator.take(n)
    }
    |> iterator.to_list
  })
  |> iterator.from_list
  |> iterator.index
  |> iterator.map(fn(e) {
    let #(i, c) = e
    i * c
  })
  |> iterator.to_list
  |> int.sum
  |> int.to_string
}
