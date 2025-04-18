module FlashHelper
    def flash_class(level)
      case level.to_sym
      when :notice then "alert-success"
      when :alert  then "alert-danger"
      else "alert-info"
      end
    end
  end