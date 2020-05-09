function test_is_same_object(this_object, that_object; except=[])
  cleaned_except = Symbol.(except)

  @test typeof(this_object) == typeof(this_object)
  all_same = _test_is_same_object(this_object, that_object, cleaned_except)

  @test all_same
end

function test_is_not_same_object(this_object, that_object; except=[])
  cleaned_except = Symbol.(except)

  is_same_object = typeof(this_object) == typeof(this_object)

  if is_same_object
    is_same_object = _test_is_same_object(this_object, that_object, cleaned_except, true)
  end

  @test !is_same_object
end

function _test_is_same_object(this_object, that_object, cleaned_except, is_silent=false)
  all_same = true

  for cur_field in fieldnames(typeof(this_object))
    ( cur_field in cleaned_except ) && continue

    this_value, that_value = getfield.([this_object, that_object], cur_field)
    ( this_value == that_value ) && continue

    if isa(this_value, AbstractDict) && isa(that_value, AbstractDict)
      this_dict, that_dict = map(cur_flat -> cur_flat.it, Base.Iterators.flatten.([this_value, that_value]))

      if sort(collect(keys(this_dict))) == sort(collect(keys(that_dict)))
        cur_keys = sort(collect(keys(this_dict)))

        actually_good = true
        for cur_key in cur_keys
          ( Symbol(cur_key) in cleaned_except ) && continue
          ( this_dict[cur_key] == that_dict[cur_key] ) && continue

          actually_good = false
          println([cur_key, this_dict[cur_key], that_dict[cur_key]])
          break
        end

        actually_good && continue
      else
        println([cur_field, this_value, that_value])
      end
    else
      println([cur_field, this_value, that_value])
    end

    all_same = false
    break
  end

  all_same
end
