mutable struct Font
  family::AbstractString
  pointsize::Int
  halign::Symbol
  valign::Symbol
  rotation::Float64
  color::Union{Nothing,AbstractString}
end

"""
    font(args...)
Create a Font from a list of features. Values may be specified either as
arguments (which are distinguished by type/value) or as keyword arguments.
# Arguments
- `family`: AbstractString. "serif" or "sans-serif" or "monospace"
- `pointsize`: Integer. Size of font in points
- `halign`: Symbol. Horizontal alignment (:hcenter, :left, or :right)
- `valign`: Symbol. Vertical aligment (:vcenter, :top, or :bottom)
- `rotation`: Real. Angle of rotation for text in degrees (use a non-integer type)
# Examples
```julia-repl
julia> font(8)
julia> font(family="serif",halign=:center,rotation=45.0)
```
"""
function font(args...;kw...)

  # defaults
  family = ""
  pointsize = -1
  halign = :hcenter
  valign = :vcenter
  rotation = 0.0
  color = nothing

  for arg in args
    T = typeof(arg)

    if T == Font
      family = arg.family
      pointsize = arg.pointsize
      halign = arg.halign
      valign = arg.valign
      rotation = arg.rotation
      color = arg.color
    elseif arg == :center
      halign = :hcenter
      valign = :vcenter
    elseif arg in (:hcenter, :left, :right)
      halign = arg
    elseif arg in (:vcenter, :top, :bottom)
      valign = arg
    elseif T <: Symbol || T <: AbstractString
      if startswith(string(arg), "#")
        color = string(arg)
      else
        family = string(arg)
      end
    elseif typeof(arg) <: Integer
      pointsize = arg
    elseif typeof(arg) <: Real
      rotation = convert(Float64, arg)
    else
      @warn("Unused font arg: $arg ($(typeof(arg)))")
    end
  end

  for symbol in keys(kw)
    if symbol == :family
      family = kw[:family]
    elseif symbol == :pointsize
      pointsize = kw[:pointsize]
    elseif symbol == :halign
      halign = kw[:halign]
      if halign == :center
        halign = :hcenter
      end
      @assert halign in (:hcenter, :left, :right)
    elseif symbol == :valign
      valign = kw[:valign]
      if valign == :center
        valign = :vcenter
      end
      @assert valign in (:vcenter, :top, :bottom)
    elseif symbol == :rotation
      rotation = kw[:rotation]
    elseif symbol == :color
      color = kw[:color]
    else
      @warn("Unused font kwarg: $symbol")
    end
  end

  Font(family, pointsize, halign, valign, rotation, color)
end

"Wrap a string with font info"
struct PlotText
  str::AbstractString
  font::Font
end
PlotText(str) = PlotText(string(str), font())

"""
    text(string, args...; kw...)
Create a PlotText object wrapping a string with font info, for plot annotations.
`args` and `kw` are passed to `font`.
"""
text(t::PlotText) = t
text(t::PlotText, font::Font) = PlotText(t.str, font)
text(str::AbstractString, f::Font) = PlotText(str, f)
function text(str, args...;kw...)
  PlotText(string(str), font(args...;kw...))
end

Base.length(t::PlotText) = length(t.str)

export text
