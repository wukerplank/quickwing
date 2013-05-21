var io = require('socket.io').listen(5000),
    services = require('./lib/services.js');

io.set('log level', 1);

var connection;

// Start server (only one time)
services.getRabbitMqConnection(function(conn) {
  if (conn) {
    connection = conn;
    var exc = conn.exchange('quickwingResults', {type: 'direct'}, function (exchange) {
      console.log('Exchange ' + exchange.name + ' is open');
    });
  } else {
    console.log("failed to connect to rabbitmq");
  }
}); 

// on socket connection
io.sockets.on('connection', function (socket) {
  
  console.log("!!!!!!!!!! Hej There! This is my socket ID: " + socket.id + "  !!!!!!!!!!!!!!!!!!!");
    
  function queue_setup(conn) {
    socket.queue = conn.queue(socket.user_uuid, {durable: true}, function() {
    
      socket.queue.subscribe(function(message, headers, deliveryInfo) {
        
        var encoded_payload = unescape(message.data)
        var payload = JSON.parse(encoded_payload)
        
        var notice = "Gleich kommt was von " + payload.source_name + "! uuid = " + socket.user_uuid + " - socket id = " + socket.id;
        
        console.log(notice);
        //console.log(payload);
        
        socket.emit('results', payload);
      }).addCallback(function(ok) { socket.ctag = ok.consumerTag; });;
    
      socket.queue.bind('quickwingResults', socket.user_uuid);
    });
  }  
  
  function queue_unsubscribe(conn) {
    console.log("-------------- START UNSUBSCRIBING!!!! --------------")
    console.log(socket.queue.unsubscribe(socket.ctag));
    console.log("-------------- FINISHED UNSUBSCRIBING!!!! --------------")
  }
   
  socket.on('uuid', function (uuid) {
    socket.user_uuid = uuid;
    queue_setup(connection);
  });
  
  socket.on('disconnect', function () {
    console.log("--------------- DISCONNECT!!!!! HELP ME !!!!! --------- a neuland production!")
    queue_unsubscribe(connection);
  });
  
});   