signature S = sig end
signature S2 = S
and S3 = S
signature S4 = sig type t end
;
signature S5 = S4 where type t = int

structure X = struct
  type t = word
  datatype point = Point of int * int
end

signature S6 = sig
  val x : int list
  val y_z : X.t
  type 'a t
  and u
  eqtype ''a f
  type 'a opt = 'a option
  datatype ('a, 'b) either = L of 'a | R of 'b | N
  datatype p = datatype X.point
  exception Eek of string
  structure X2 : S
  ;
  include S2
  include sig end
  structure X3: S4 sharing type u = X3.t
end

functor F (X: S4) : S4 = struct open X end
and F2 (X: S) :> S = X
  ;
functor F3 (val x:int) = struct val y = x end

structure FofX = F(X)
and F3ofX = F3(val x = 5)
  ;
structure S = let
  val x = 3
in
  struct val y = x + 1
  end
end

val 'a SOME(x) = SOME(5)
and y = 5+1
val rec fact = fn n => if n = 0 then 1 else n * fact (n-1)

infix 4 $
infixr %
fun f (SOME(x)) : int = x
  | f NONE = 0
and op& y = y + 1
and x $ y = x y
and (x % y) z = (x y) z

type 'a opt = 'a option
datatype ('a, 'b) either = L of 'a | R of 'b | N
type dollars = int
structure Sets = struct
  abstype absset = Set of int list
  with
    val empty = Set []
    fun insert(x, Set s) = Set (x::s)
    fun member (x, Set s) = case s
                              of [] => false
                               | (h::t) => (x = h) orelse member (x, Set t)
  end
end
;
structure Exns = struct
  exception Eek of string
end
exception E = Exns.Eek
local open Sets
in fun build xs = foldl insert empty xs
end
nonfix %

type 'a b = 'a
and 'a optagain = 'a Option.option
and g = (int opt)
and fs = Sets.absset -> int -> Sets.absset
and tups = dollars * real
and recs = {x:real, y:real}

fun z ([_, x, y]) = x + y
  | z (op :: (1,List.nil)) = 1
  | z (xs as h::t) = h
  | z _ = 0
fun x {1=x, 2=y} = x * y
fun c {x=ex, y=wy} = x (ex, wy)

fun v x = raise E "ek"
fun b x = (v x) handle E e => print e

structure S = struct
  val w = 0w23
  val hex = ~0xab
  val ff = 1.2
  val ff3 = 1.2e~1
  val x = ~2
  val A = ~1
  val xx = 0
  val YYY = 1
  val YyY = 2
  val yYy = 3
  val d = #"t"
  val c = #"\t"
  val ss = "hello`| world!\\n"
end

(* this is a comment val x = y *)
val x = "(* this is not *)"
