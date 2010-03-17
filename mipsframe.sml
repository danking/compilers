structure MipsFrame : FRAME =
struct
  val offset = ~4
  datatype access = InFrame of int | InReg of Temp.temp
  type frame = {formals : access list, localCount : int ref,
                name : Temp.label, frameOffset : int ref}

  fun escapeToAccess (true, (access, frameOffset)) =
        (InFrame (frameOffset + offset) :: access, frameOffset + offset)
    | escapeToAccess (false, (access, frameOffset)) =
        (InReg (Temp.newtemp ()) :: access, frameOffset)

  fun newFrame {name, formals} =
    let
      val (formals, frameOffset) = (foldr escapeToAccess ([], 0) formals)
    in
      {name = name, formals = formals,
       localCount = ref 0, frameOffset = ref frameOffset}
    end

  fun name (f : frame) = #name f
  fun formals (f : frame) = #formals f

  fun allocLocal (frame : frame) true =
        let
          val localCount = #localCount frame
          val frameOffset = #frameOffset frame
        in
          (localCount := !localCount + 1;
           frameOffset := !frameOffset + offset;
           InFrame (!frameOffset))
        end
    | allocLocal frame false =
        let
          val localCount = #localCount frame
        in
          (localCount := !localCount + 1;
           InReg (Temp.newtemp ()))
        end
end

structure Frame : FRAME = MipsFrame
