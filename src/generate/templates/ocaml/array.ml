module {module_name} = struct
  type t = futhark_array

  let free t = ignore (Bindings.futhark_free_{elemtype}_{rank}d t.ctx.Context.handle t.ptr)
  
  let v ctx ba =
    let dims = Genarray.dims ba in
    let ptr = Bindings.futhark_new_{elemtype}_{rank}d ctx.Context.handle (bigarray_start genarray ba) {dim_args} in
    if is_null ptr then raise (Error NullPtr);
    let t = {{ ptr; ctx; shape = dims; }} in
    Gc.finalise free t; t

  let values t ba =
    let dims = Genarray.dims ba in
    let a = Array.fold_left ( * ) 1 t.shape in
    let b = Array.fold_left ( * ) 1 dims in
    if (a <> b) then raise (Error (InvalidShape (a, b)));
    let rc = Bindings.futhark_values_{elemtype}_{rank}d t.ctx.Context.handle t.ptr (bigarray_start genarray ba) in
    if rc <> 0 then raise (Error (Code rc))

  let shape t = t.shape

  let raw_shape ctx ptr =
    let s = Bindings.futhark_shape_{elemtype}_{rank}d ctx ptr in
    Array.init {rank} (fun i -> Int64.to_int !@ (s +@ i))

  let of_raw ctx ptr =
    if is_null ptr then raise (Error NullPtr);
    let shape = raw_shape ctx.Context.handle ptr in
    let t = {{ ptr; ctx; shape }} in
    Gc.finalise free t; t
    
  let _ = of_raw
end
