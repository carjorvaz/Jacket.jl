include("langs/Stacker.jl")

const julia_parser = getglobal(Core, :_parse)

restore_julia_parser() = begin
    Core._setparser!(julia_parser)
    # :julia
end

get_parser_for(str) =
    nothing

lang_parser(text::Union{Core.SimpleVector,String}, filename::String, lineno, offset, options) =
    # Does the file start with #lang:<language>?
    let matched = offset == 0 ? match(r"^#lang:(.+?)\r?\n(.+)$"s, text) : nothing
        # If not, use Julia's parser
        isnothing(matched) ?
        julia_parser(text, filename, lineno, offset, options) :

        # If so, get that language's parser
        let (lang, text) = matched,
            parser = get_parser_for(lang)

            ##
            # println("Using parser '$parser'")
            ##

            isnothing(parser) ?
            (Expr(:incomplete, "No parser found for language '$lang'"), offset) :
            parser(text, filename, lineno, offset, options)
        end
    end

lang_parser(text::AbstractString, filename::AbstractString, lineno, offset, options) =
    lang_parser(String(text), String(filename), lineno, offset, options)

install_jacket_parser() = begin
    Core._setparser!(lang_parser)
    # :jacket
end
