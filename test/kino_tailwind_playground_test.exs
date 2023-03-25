defmodule KinoTailwindPlaygroundTest do
  use ExUnit.Case
  doctest KinoTailwindPlayground

  test "greets the world" do
    assert KinoTailwindPlayground.hello() == :world
  end
end
