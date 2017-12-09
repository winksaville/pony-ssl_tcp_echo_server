use "net"
use "net/ssl"
use "files"

class ServerConnNotify is TCPConnectionNotify
  let _out: OutStream

  new create(out: OutStream) =>
    _out = out

  fun ref accepted(conn: TCPConnection ref) =>
    _out.print("ServerConnNotify.accepted:")

  fun ref connecting(conn: TCPConnection ref, count: U32) =>
    _out.print("ServerConnNotify.connecting: count=" + count.string())

  fun ref connected(conn: TCPConnection ref) =>
    _out.print("ServerConnNotify.connected: writing \"Hello\"")
    conn.write("Hello")

  fun ref connect_failed(conn: TCPConnection ref) =>
    _out.print("ServerConnNotify.connect_failed: FAILED")

  fun ref auth_failed(conn: TCPConnection ref) =>
    _out.print("ServerConnNotify.auth_failed:")

  fun ref sent(conn: TCPConnection ref, data: ByteSeq): ByteSeq =>
    _out.print("ServerConnNotify.sent: data=" + try data as String else "<data wasn't string>" end)
    data

  fun ref sentv(conn: TCPConnection ref, data: ByteSeqIter): ByteSeqIter =>
    conn.write("ServerConnNotify.sentv:")
    data

  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize)
    : Bool
  =>
    let s = String.from_array(consume data)
    _out.print("ServerConnNotify.received: data=" + s)
    conn.write(s)
    true

  fun ref expect(conn: TCPConnection ref, qty: USize): USize =>
    _out.print("ServerConnNotify.expect: qty=" + qty.string())
    qty

  fun ref closed(conn: TCPConnection ref) =>
    _out.print("ServerConnNotify.closed:")

  fun ref throttled(conn: TCPConnection ref) =>
    _out.print("ServerConnNotify.throttled:")

  fun ref unthrottled(conn: TCPConnection ref) =>
    _out.print("ServerConnNotify.unthrottled:")


class iso ServerListenNotify is TCPListenNotify
  let _env: Env
  let _out: OutStream

  new create(env: Env) =>
    _env = env
    _out = _env.out

  fun ref listening(listen: TCPListener ref) =>
    _out.print("ServerListenNotify.litening:")

  fun ref not_listening(listen: TCPListener ref) =>
    _out.print("ServerListenNotify.not_listening:")

  fun ref closed(listen: TCPListener ref) =>
    _out.print("ServerListenNotify.closed:")

  fun ref connected(listen: TCPListener ref): TCPConnectionNotify iso^ ? =>
    try
      _out.print("ServerListenNotify.connected:")
      let auth = try _env.root as AmbientAuth else _out.print("error root is not AmbientAuth"); error end
      _out.print("ServerListenNotify.connected: 1")
      let cert_path = try FilePath(auth, "./cert.pem")? else _out.print("error no cert.pem"); error end
      _out.print("ServerListenNotify.connected: 2.1")
      let key_path = try FilePath(auth, "./key.pem")? else _out.print("error no key.pem"); error end
      _out.print("ServerListenNotify.connected: 2.2")
      let ssl_ctx = SSLContext
      _out.print("ServerListenNotify.connected: 2.3")
      try ssl_ctx.set_authority(cert_path)? else _out.print("error set_authority"); error end
      _out.print("ServerListenNotify.connected: 2.4")
      try ssl_ctx.set_cert(cert_path, key_path)? else _out.print("error set_cert"); error end
      _out.print("ServerListenNotify.connected: 2.5")
      // Only works if verify server is off, client can be on or off???
      ssl_ctx.>set_server_verify(false).>set_client_verify(true)
      _out.print("ServerListenNotify.connected: 2.6")
      let ssl_server = try ssl_ctx.server()? else _out.print("no server ssl context"); error end
      _out.print("ServerListenNotify.connected: 3")
      let my_tcp_conn_notify: TCPConnectionNotify iso = recover ServerConnNotify(_out) end
      _out.print("ServerListenNotify.connected: 4")
      SSLConnection(consume my_tcp_conn_notify, consume ssl_server)
    else
      _out.print("ServerListenNotify.connected: error")
      error
    end

actor Main
  new create(env: Env) =>
    try
      TCPListener(env.root as AmbientAuth,
        recover ServerListenNotify(env) end, "", "8989")
    end
