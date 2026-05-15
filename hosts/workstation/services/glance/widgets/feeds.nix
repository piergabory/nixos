{ lib }:

let
  inherit (lib) split;
in

[
  (split [
    {
      type = "rss";
      title = "News";
      cache = "30m";
      limit = 6;
      collapse-after = -1;
      preserve-order = true;
      single-line-titles = true;
      feeds = [
        {
          title = "NYTimes";
          url = "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml";
          limit = 2;
        }
        {
          title = "The Verge";
          url = "https://www.theverge.com/rss/index.xml";
          limit = 2;
        }
        {
          title = "Le Monde";
          url = "https://www.lemonde.fr/rss/une.xml";
          limit = 2;
        }
      ];
    }
    {
      type = "rss";
      title = "Podcasts";
      cache = "2h";
      limit = 12;
      collapse-after = 6;
      single-line-titles = true;
      feeds = [
        {
          title = "The Vergecast";
          url = "https://feeds.megaphone.fm/vergecast";
          limit = 3;
        }
        {
          title = "Waveform";
          url = "https://feeds.megaphone.fm/STU4418364045";
          limit = 3;
        }
        {
          title = "Decoder";
          url = "https://feeds.megaphone.fm/recodedecode";
          limit = 3;
        }
        {
          title = "Dear Hank & John";
          url = "https://rss.art19.com/dear-hank-john";
          limit = 3;
        }
        {
          title = "The Layover";
          url = "https://podcasts.watchnebula.com/thelayover/eed363ef77c14827802f60575261176a";
          limit = 3;
        }
      ];
    }
  ])
]
