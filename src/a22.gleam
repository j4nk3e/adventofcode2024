import argv
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/result
import gleam/string
import parallel_map
import stdin.{stdin}
import util.{parse}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.println
}

fn in() {
  stdin()
  |> iterator.map(string.trim)
  |> iterator.map(parse)
  |> iterator.to_list
}

fn prune(n) {
  int.bitwise_and(n, 16_777_216 - 1)
}

const shl = int.bitwise_shift_left

const shr = int.bitwise_shift_right

const xor = int.bitwise_exclusive_or

fn next(n) {
  let m = n |> xor(shl(n, 6)) |> prune
  let o = m |> xor(shr(m, 5)) |> prune
  o |> xor(shl(o, 11)) |> prune
}

fn times(n, secret, f) {
  case n {
    0 -> secret
    _ -> times(n - 1, f(secret), f)
  }
}

fn ones(n) {
  n % 10
}

fn a() {
  in()
  |> list.fold(0, fn(acc, s) {
    let r = times(2000, s, next)
    acc + r
  })
  |> int.to_string
}

fn window(n, w, seq, sec) {
  case n {
    0 -> 0
    _ ->
      case w {
        h if seq == h -> ones(sec)
        _ -> {
          let ns = next(sec)
          let d = ones(ns) - ones(sec)
          let w =
            w |> list.reverse |> list.take(3) |> list.prepend(d) |> list.reverse
          window(n - 1, w, seq, ns)
        }
      }
  }
}

fn all_seq(ps) {
  let s = next_seq(ps)
  case s {
    [] -> []
    _ -> [s, ..all_seq(s)]
  }
}

fn next_seq(s) {
  let assert [a, b, c, d] = s
  case d {
    9 -> {
      case c {
        9 -> {
          case b {
            9 -> {
              case a {
                9 -> []
                _ -> [a + 1, -9, -9, -9]
              }
            }
            _ -> [a, b + 1, -9, -9]
          }
        }
        _ -> [a, b, c + 1, -9]
      }
    }
    _ -> [a, b, c, d + 1]
  }
}

fn b() {
  let n = in()
  all_seq([-9, -9, -9, -9])
  |> parallel_map.list_pmap(
    fn(seq) {
      io.debug(seq)
      list.fold(n, 0, fn(acc, s) {
        let r = window(2000, [], seq, s)
        acc + r
      })
    },
    parallel_map.MatchSchedulersOnline,
    10_000,
  )
  |> result.values
  |> list.reduce(int.max)
  |> util.unwrap
  |> int.to_string
}
