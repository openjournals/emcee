module Emcee
  module Processors
    # ScriptProcessor scans a document for external script references and inlines
    # them into the current document.
    class ScriptProcessor
      def initialize(resolver)
        @resolver = resolver
      end

      def process(doc)
        inline_scripts(doc)
        doc
      end

      private

      def inline_scripts(doc)
        doc.script_references.each do |node|
          next unless @resolver.should_inline?(node.path)
          path = @resolver.absolute_path(node.path)
          script = @resolver.evaluate(path)
          node.replace("script", escape_with_slash(script))
          @resolver.depend_on_asset(path)
        end
      end

      def escape_with_slash(script)
        script = script.sub('<!--', '<!\\--')
        script.gsub!(/<\/\s*script/i) do |match|
          match.sub '</', '<\\/'
        end
        script
      end
    end
  end
end
