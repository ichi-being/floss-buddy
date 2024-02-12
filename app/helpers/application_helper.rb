module ApplicationHelper
  def page_title(title = '')
    base_title = 'Floss Buddy'
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  def default_meta_tags
    {
      site: 'Floss Buddy',
      title: 'LINEで手軽に。フロスの習慣化！',
      reverse: true,
      charset: 'utf-8',
      description: 'LINEでフロスの習慣化をサポートするアプリです。',
      keywords: 'フロス,デンタルフロス,オーラルケア',
      canonical: request.original_url,
      separator: '|',
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: request.original_url,
        image: image_url('OGP.png'),
        local: 'ja-JP'
      },
      # Twitter用の設定を個別で設定する
      twitter: {
        card: 'summary_large_image', # Twitterで表示する場合は大きいカードにする
        site: '@ichi_being', # アプリの公式Twitterアカウントがあれば、アカウント名を書く
        image: image_url('OGP.png') # 配置するパスやファイル名によって変更すること
      }
    }
  end

end
