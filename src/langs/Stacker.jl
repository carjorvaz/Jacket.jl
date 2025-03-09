# TODO:
# - Expr(:incomplete) for the REPL

stacker_parser(text::Union{Core.SimpleVector,String}, filename::String, lineno, offset, options) =
    let stack = []
        offset += 1
        while offset <= length(text)
            c = text[offset]

            # If whitespace, skip
            if isspace(c)
                offset += 1

            # If number, add to stack
            elseif isdigit(c)
                num_str = ""
                while offset <= length(text) && isdigit(text[offset])
                    num_str *= text[offset]
                    offset += 1
                end

                num = parse(Int, num_str)
                push!(stack, num)

            # If operator (+ or *), pop top two elements from stack and build Expr
            elseif c in ('+', '*')
                if length(stack) < 2
                    error("$filename:$lineno:$offset: operator '$c' needs 2 operands")
                end

                r = pop!(stack)
                l = pop!(stack)
                push!(stack, Expr(:call, Symbol(c), l, r))

                offset += 1
            else
                error("$filename:$lineno:$offset: invalid token '$c'")
            end
        end
        (Expr(:toplevel, stack...), offset)
    end

stacker_parser(text::AbstractString, filename::AbstractString, lineno, offset, options) =
    stacker_parser(String(text), String(filename), lineno, offset, options)
