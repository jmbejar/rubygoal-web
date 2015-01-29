$SAFE = 4

begin
  system "echo 10"
rescue SecurityError
end

$SAFE = 1

system "echo 10"
