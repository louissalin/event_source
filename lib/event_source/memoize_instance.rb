module EventSource
    module MemoizeInstance
        def current
            @instance ||= self.send(:new, *default_args())
        end

        def create(*args)
            @instance = self.send(:new, *args)
        end

        def default_args
            []
        end
    end
end
