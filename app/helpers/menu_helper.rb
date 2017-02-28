module MenuHelper
  LINE_BREAK = "\n"
  TAB_INDEX = 2
  WHITE_SPACE = ' '

  def build_menu_header(options = {})
    menu = []
    menu << _break_tab('<nav class="navbar navbar-toggleable-md fixed-top">')
    menu.concat(_button_icon)
    menu << _home_menu_item(options)
    menu.concat(_container_menu_items(options))
    menu << _break_tab('</nav>')
    menu.concat(_container_title)

    menu.join.html_safe
  end

  def build_menu_footer

  end

  private

  def _break_tab(text_excerpt, tabs = 0)
    text = LINE_BREAK.dup
    text << WHITE_SPACE * (tabs * TAB_INDEX) if tabs > 0
    text << text_excerpt
  end

  def _container_menu_items(options)
    container = []
    container << _break_tab('<div class="collapse navbar-collapse justify-content-end" id="navbarCollapse">', 1)
    container << _break_tab('<ul class="navbar-nav">', 2)

    options[:menu_items] ||= []
    menu_items = options[:menu_items].collect do |item|
      _menu_item item[:label], item[:path]
    end
    container.concat menu_items
    container.concat _authentication_menu_item

    container << _break_tab('</ul>', 2)
    container << _break_tab('</div>', 1)
  end

  def _menu_item(label, path)
    menu = []
    menu << _break_tab('<li class="nav-item">', 3)
    menu << _break_tab('<h5>', 4)
    menu << link_to(label, path, class: 'nav-link')
    menu << '</h5>'
    menu << _break_tab('</li>', 3)
  end

  def _home_menu_item(options)
    path = (options[:home_path]) ? options[:home_path] : home_path
    _break_tab(link_to(I18n.translate('menu.header.home'), path, class: 'navbar-brand'), 1)
  end

  def _authentication_menu_item
    if session[:user_so].nil?
      _signin_menu_item
    else
      _signout_menu_item
    end
  end

  def _signin_menu_item
    menu = []
    menu << _break_tab('<li class="nav-item">', 3)
    menu << _break_tab('<h5>', 4)
    menu << link_to(t('menu.header.login'), login_path, class: 'nav-link')
    menu << '</h5>'
    menu << _break_tab('</li>', 3)
  end

  def _signout_menu_item
    menu = []
    menu << _break_tab('<li class="nav-item">', 3)
    menu << _break_tab('<h5>', 4)
    menu << link_to(t('menu.header.sign_out'), signout_path, method: :delete, class: 'nav-link')
    menu << '</h5>'
    menu << _break_tab('</li>', 3)
  end

  def _container_title
    menu = []
    menu << _break_tab('<br/><br/>')
    menu << _break_tab('<div class="jumbotron text-center">')
    menu << _break_tab("<h1>#{I18n.translate 'menu.header.title'}</h1>", 1)
    menu << _break_tab("<p>#{I18n.translate 'menu.header.subtitle'}</p>", 1)
    menu << _break_tab('</div>')
  end

  def _button_icon
    menu = []
    menu << _break_tab(
      '<button class="navbar-toggler navbar-toggler-right" type="button" data-toggle="collapse" ' +
      'data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" ' +
      'aria-label="Toggle navigation">', 1
    )
    menu << _break_tab('<span class="navbar-toggler-icon"></span>', 2)
    menu << _break_tab('</button>', 1)
  end
end