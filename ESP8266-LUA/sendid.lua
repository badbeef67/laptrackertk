function check_pin(pin)
	pinValue = gpio.read(pin);
	id = node.chipid()
	if pinValue == 0 then
		conn=net.createConnection(net.TCP, 0);
		conn:on("receive", function(conn, payload) print(payload) end);
		conn:connect(65000,'192.168.1.254');
		conn:send(id);
		conn:send("\r");
		gpio.write(3,gpio.HIGH);
	else
	gpio.write(3,gpio.HIGH);
	end;
end;

gpio.mode(3, gpio.INPUT);
check_pin(3);
