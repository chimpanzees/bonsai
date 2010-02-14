module YARD
  module Templates
    module Helpers
      module TextHelper
        def h(text)
          out = ""
          text = text.split(/\n/)
          text.each_with_index do |line, i|
            out << 
            case line
            when /^\s*$/; "\n\n"
            when /^\s+\S/, /^=/; line + "\n"
            else; line + (text[i + 1] =~ /^\s+\S/ ? "\n" : " ")
            end
          end
          out
        end

        def wrap(text, col = 72)
          text.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\3\n") 
        end
                
        def indent(text, len = 4)
          text.gsub(/^/, ' ' * len)
        end
        
        def title_align_right(text, col = 72)
          align_right(text, '-', col)
        end
        
        def align_right(text, spacer = ' ', col = 72)
          spacer * (col - 1 - text.length) + " " + text
        end
        
        def hr(col = 72, sep = "-")
          sep * col
        end
        
        def signature(meth)
          # use first overload tag if it has a return type and method itself does not
          if !meth.tag(:return) && meth.tag(:overload) && meth.tag(:overload).tag(:return)
            meth = meth.tag(:overload)
          end

          type = options[:default_return] || ""
          if meth.tag(:return) && meth.tag(:return).types
            types = meth.tags(:return).map {|t| t.types ? t.types : [] }.flatten
            first = types.first
            if types.size == 2 && types.last == 'nil'
              type = first + '?'
            elsif types.size == 2 && types.last =~ /^(Array)?<#{Regexp.quote types.first}>$/
              type = first + '+'
            elsif types.size > 2
              type = [first, '...'].join(', ')
            elsif types == ['void'] && options[:hide_void_return]
              type = ""
            else
              type = types.join(", ")
            end
          end
          type = "(#{type})" if type.include?(',')
          type = " -> #{type} " unless type.empty?
          scope = meth.scope == :class ? "#{meth.namespace.name}." : "#{meth.namespace.name.to_s.downcase}."
          name = meth.name
          blk = format_block(meth)
          args = format_args(meth)
          extras = []
          extras_text = ''
          if rw = meth.namespace.attributes[meth.scope][meth.name]
            attname = [rw[:read] ? 'read' : nil, rw[:write] ? 'write' : nil].compact
            attname = attname.size == 1 ? attname.join('') + 'only' : nil
            extras << attname if attname
          end
          extras << meth.visibility if meth.visibility != :public
          extras_text = '(' + extras.join(", ") + ')' unless extras.empty?
          title = "%s%s%s %s%s%s" % [scope, name, args, blk, type, extras_text]
          title.gsub(/\s+/, ' ')
        end
      end
    end
  end
end