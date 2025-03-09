module Jacket
include("JacketParser.jl")

__init__() = begin
    install_jacket_parser()
end

end # module Jacket
