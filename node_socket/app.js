var io = require('socket.io').listen(5000),
    services = require('./lib/services.js');

io.set('log level', 1);

var connection;

// Start server
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

io.sockets.on('connection', function (socket) {
  
  var user_uuid;
  
  function setup(conn) {
    var queue = conn.queue(user_uuid, {}, function() {
    
      queue.subscribe(function(message, headers, deliveryInfo) {
        
        var encoded_payload = unescape(message.data)
        var payload = JSON.parse(encoded_payload)
        
        var notice = "Gleich kommt was! uuid = " + user_uuid + " - socket id = " + socket.id;
        
        console.log(notice);
        console.log(payload);
        
        socket.emit('results', payload);
      });
    
      queue.bind('quickwingResults', user_uuid);
    });
  }  
   
  socket.on('uuid', function (uuid) {
    user_uuid = uuid;
    setup(connection);
  });
  
  socket.on('disconnect', function () {
    console.log("--------------- DISCONNECT!!!!! HELP ME !!!!! --------- a neuland production!")
  });
  
});   