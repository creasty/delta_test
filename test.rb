require 'awesome_print'

$_counter = 0

def create
  $_counter += 1
  { item: nil, next: nil, id: $_counter }
end

$root = { tail: nil, head: nil }
# $root[:tail] = $root[:head] = create

def add(item)
  list = nil

  if $root[:tail]
    if !$root[:tail][:item]
      list = $root[:tail]
      $root[:head] = list
    elsif $root[:tail][:next]
      p 1
      list = $root[:tail][:next]
    else
      p 2
      list = create
      $root[:tail][:next] = list
    end
  else
    p 3
    list = create
    $root[:head] = list
  end

  $root[:tail] = list
  list[:item] = item
end

def clean
  $root[:tail] = $root[:head]
  list = $root[:tail]

  while list
    list[:item] = nil
    list = list[:next]
  end
end

ap $root

add('a')
add('b')
add('c')

ap $root

clean

ap $root
add('a')
add('b')
add('c')

ap $root

