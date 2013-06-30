module EventSource
    module MemoizeInstance
        def current
            @instance ||= self.send(:new, *default_args())
        end

        def default_args
            []
        end
    end
end
