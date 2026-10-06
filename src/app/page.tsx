import {
  ArrowRight,
  Article,
  Briefcase,
  ChatCircleDots,
  Gauge,
  Heartbeat,
  Info,
  Lightbulb,
  MicrophoneStage,
  TreeStructure,
  UsersThree,
  Waveform,
} from "@phosphor-icons/react/ssr";
import styles from "./page.module.css";

const problems = [
  {
    Icon: Heartbeat,
    title: "Le trac prend le dessus",
    text: "Pour un seul poste, des centaines de candidats. La pression fait perdre ses moyens, même aux meilleurs profils.",
  },
  {
    Icon: ChatCircleDots,
    title: "Les « euh » s’installent",
    text: "On parle trop vite, on se répète, on perd le fil. Sans retour honnête, impossible de savoir ce qui cloche.",
  },
  {
    Icon: UsersThree,
    title: "Personne pour s’entraîner",
    text: "Un coach coûte cher, les proches n’osent pas critiquer. Alors on arrive à l’entretien sans s’être jamais entendu.",
  },
];

const modes = [
  {
    kicker: "Mode 1",
    Icon: Briefcase,
    title: "Prépare mon entretien",
    text: "Importe ton CV et la fiche de poste. L’IA prépare les questions RH et techniques que le recruteur risque vraiment de te poser.",
    tags: ["5 ou 10 questions", "Français ou anglais"],
    action: "Préparer un entretien",
  },
  {
    kicker: "Mode 2",
    Icon: MicrophoneStage,
    title: "Entraîne mon éloquence",
    text: "L’IA te propose un sujet. Tu as 1 à 2 minutes pour convaincre. Idéal pour gagner en aisance au quotidien, réunion après réunion.",
    tags: ["Sujet surprise", "1 à 2 minutes"],
    action: "Lancer un sujet",
  },
];

const steps = [
  {
    title: "Choisis ton mode",
    text: "Un entretien précis avec ton CV et l’offre, ou un sujet d’éloquence au hasard.",
  },
  {
    title: "Réponds face caméra",
    text: "Depuis ton téléphone ou ton ordinateur. Personne ne te regarde : tu peux recommencer autant que tu veux.",
  },
  {
    title: "Reçois ton rapport",
    text: "Contenu, structure, tics de langage, débit : ce qui marche déjà, et une piste concrète pour la prochaine fois.",
  },
];

const criteria = [
  { Icon: Article, text: "Contenu : pertinence et exemples" },
  { Icon: TreeStructure, text: "Structure : début, milieu, conclusion" },
  { Icon: Waveform, text: "Tics de langage : « euh », « en fait »…" },
  { Icon: Gauge, text: "Débit : ni trop vite, ni trop lent" },
];

// Barres en segments du rapport d'exemple : "full", "partial" ou "empty".
type Segment = "full" | "partial" | "empty";
const segmentMetrics: {
  label: string;
  value: string;
  unit?: string;
  segments: Segment[];
  note: string;
}[] = [
  {
    label: "Tics de langage",
    value: "12",
    unit: "« euh »",
    segments: ["full", "full", "empty", "empty"],
    note: "À travailler",
  },
  {
    label: "Structure",
    value: "3/4",
    unit: "étapes",
    segments: ["full", "full", "full", "empty"],
    note: "Conclusion manquante",
  },
  {
    label: "Contenu",
    value: "Solide",
    segments: ["full", "full", "full", "partial"],
    note: "Exemples concrets",
  },
];

const testimonials = [
  {
    quote: "Je bloquais toujours sur “Parlez-moi de vous”. Après cinq sessions, j’avais enfin une réponse claire.",
    name: "Awa",
    detail: "24 ans, diplômée en marketing, Dakar",
  },
  {
    quote: "Le rapport m’a montré que je parlais beaucoup trop vite. Je ne m’en rendais pas du tout compte.",
    name: "Moussa",
    detail: "27 ans, développeur, Thiès",
  },
  {
    quote: "J’ai préparé mon entretien en anglais avec le mode 10 questions. Le jour J, plus aucune surprise.",
    name: "Fatou",
    detail: "31 ans, comptable, Saint-Louis",
  },
];

const footerLinks = [
  { href: "#modes", label: "Les modes" },
  { href: "#", label: "Confidentialité" },
  { href: "#", label: "À propos" },
  { href: "#", label: "Conditions d’utilisation" },
  { href: "#", label: "Contact" },
  { href: "#", label: "Se connecter" },
];

const waveHeights = [10, 20, 28, 14, 24, 8, 18, 12];

function Wordmark() {
  return (
    <span className={styles.wordmark}>
      waxtan<span className={styles.wordmarkDot}>.</span>
    </span>
  );
}

function InkBar({ large = false }: { large?: boolean }) {
  return (
    <span className={large ? styles.inkBarLarge : styles.inkBar}>
      <span className={styles.inkC} />
      <span className={styles.inkM} />
      <span className={styles.inkY} />
    </span>
  );
}

// Chiffre façon impression CMJN : le .paper porte le texte pour les lecteurs
// d'écran, les trois plaques colorées sont décoratives.
function PlateNumber({ value }: { value: number }) {
  return (
    <div className={`cmyk-num ${styles.stepNumber}`}>
      <span className="paper">{value}</span>
      <span className="plate plate-c" aria-hidden="true">{value}</span>
      <span className="plate plate-m" aria-hidden="true">{value}</span>
      <span className="plate plate-y" aria-hidden="true">{value}</span>
    </div>
  );
}

function CtaButton() {
  // Pas encore de parcours d'inscription : le bouton mène aux modes.
  return (
    <a href="#modes" className={`btn btn-primary ${styles.ctaButton}`}>
      Commencer gratuitement <ArrowRight size={20} weight="duotone" />
    </a>
  );
}

export default function Home() {
  return (
    <div className={styles.page}>
      <header className={styles.header}>
        <a href="#" className={styles.brand} aria-label="Waxtan, accueil">
          <Wordmark />
          <InkBar />
        </a>
        <button type="button" className={`btn btn-secondary ${styles.headerButton}`}>
          Se connecter
        </button>
      </header>

      <main className={styles.main}>
        <section className={styles.hero}>
          <div className={styles.heroText}>
            <span className={styles.greeting}>
              Nanga def ? · Coach IA de prise de parole
            </span>
            <h1 className={styles.heroTitle}>
              Ta voix, ton meilleur{" "}
              <span className={styles.accentItalic}>atout.</span>
            </h1>
            <p className={styles.heroLead}>
              Entraîne-toi face caméra pour tes entretiens et tes prises de
              parole. Waxtan t’écoute, puis te dit ce qui marche déjà et comment
              progresser.
            </p>
            <div className={styles.cta}>
              <CtaButton />
              <span className={styles.muted}>
                Gratuit · Sans carte bancaire · Prêt en 2 minutes
              </span>
            </div>
          </div>

          <div className={styles.heroVisual} aria-hidden="true">
            <div className={`halftone ${styles.heroBackdrop}`} />
            <div className={`card elev-md ${styles.recorder}`}>
              <div className={styles.rowBetween}>
                <span className={styles.muted}>Question 3 sur 5</span>
                <span className={styles.recBadge}>
                  <span className={styles.recDot} />
                  REC 01:12
                </span>
              </div>
              <div className={styles.progress}>
                {[0, 1, 2, 3, 4].map((i) => (
                  <span key={i} className={i < 3 ? styles.done : undefined} />
                ))}
              </div>
              <p className={styles.question}>
                « Parlez-moi d’une situation où vous avez dû convaincre un client
                difficile. »
              </p>
              <div className={styles.speaking}>
                <span className={styles.waveform}>
                  {waveHeights.map((h, i) => (
                    <span key={i} style={{ height: h }} />
                  ))}
                </span>
                <span className={styles.muted}>Tu parles…</span>
              </div>
            </div>
          </div>
        </section>

        <section className={styles.section}>
          <h6 className={styles.eyebrow}>Le problème</h6>
          <h2 className={styles.sectionTitle}>
            Tu connais ton métier. Mais le jour J, les mots ne viennent pas.
          </h2>
          <div className={styles.problems}>
            {problems.map(({ Icon, title, text }) => (
              <div key={title} className={styles.problem}>
                <Icon size={30} weight="duotone" className={styles.icon} />
                <h4>{title}</h4>
                <p className={styles.text}>{text}</p>
              </div>
            ))}
          </div>
        </section>

        <section id="modes" className={styles.section}>
          <h6 className={styles.eyebrow}>Deux façons de t’entraîner</h6>
          <h2 className={styles.sectionTitle}>
            Un objectif précis, ou juste l’envie de mieux parler.
          </h2>
          <div className={styles.modes}>
            {modes.map(({ kicker, Icon, title, text, tags, action }) => (
              <div key={title} className={`card ${styles.mode}`}>
                <div className={styles.rowBetween}>
                  <span className={`card-kicker ${styles.modeKicker}`}>{kicker}</span>
                  <Icon size={32} weight="duotone" className={styles.icon} />
                </div>
                <div className={`card-title ${styles.modeTitle}`}>{title}</div>
                <p className={`card-body ${styles.modeBody}`}>{text}</p>
                <div className={styles.tags}>
                  {tags.map((tag) => (
                    <span key={tag} className="tag tag-accent">{tag}</span>
                  ))}
                </div>
                <div className={styles.modeLink}>
                  {action} <ArrowRight weight="duotone" />
                </div>
              </div>
            ))}
          </div>
        </section>

        <section className={styles.section}>
          <h6 className={styles.eyebrow}>Comment ça marche</h6>
          <div className={styles.steps}>
            {steps.map(({ title, text }, i) => (
              <div key={title} className={styles.step}>
                <PlateNumber value={i + 1} />
                <h3>{title}</h3>
                <p className={styles.text}>{text}</p>
              </div>
            ))}
          </div>
        </section>

        <section className={styles.reportSection}>
          <div className={styles.reportIntro}>
            <h6 className={styles.eyebrow}>Le rapport d’analyse</h6>
            <h2 className={styles.sectionTitle}>Un retour de coach, pas une note.</h2>
            <p className={styles.text}>
              Chaque rapport commence par tes points forts. Puis des pistes
              précises, avec des exemples tirés de ta propre réponse.
            </p>
            <ul className={styles.criteria}>
              {criteria.map(({ Icon, text }) => (
                <li key={text}>
                  <Icon size={22} weight="duotone" className={styles.icon} />
                  {text}
                </li>
              ))}
            </ul>
          </div>

          <div className={`card elev-md ${styles.report}`}>
            <div className={styles.reportHeader}>
              <span className="tag tag-neutral">Exemple de rapport</span>
              <span className={styles.muted}>Entretien · Chargé de clientèle</span>
            </div>
            <div className={styles.strength}>
              <span className="tag tag-accent-2">Ton point fort</span>
              <p className={styles.quote}>
                « Ton exemple du client mécontent était concret et bien raconté.
                Le recruteur s’en souviendra. »
              </p>
            </div>
            <div className={styles.metrics}>
              <div className={styles.metric}>
                <span className={`card-kicker ${styles.metricLabel}`}>Débit</span>
                <div className={styles.metricValue}>
                  <span className={styles.metricNumber}>138</span>
                  <span className={styles.muted}>mots/min</span>
                </div>
                <div className={styles.gauge}>
                  <div className={styles.gaugeZone} />
                  <div className={styles.gaugeMarker} />
                </div>
                <span className={styles.muted}>Zone idéale</span>
              </div>
              {segmentMetrics.map(({ label, value, unit, segments, note }) => (
                <div key={label} className={styles.metric}>
                  <span className={`card-kicker ${styles.metricLabel}`}>{label}</span>
                  <div className={styles.metricValue}>
                    <span className={styles.metricNumber}>{value}</span>
                    {unit && <span className={styles.muted}>{unit}</span>}
                  </div>
                  <div className={styles.segments}>
                    {segments.map((s, i) => (
                      <span
                        key={i}
                        className={s === "empty" ? undefined : styles[s]}
                      />
                    ))}
                  </div>
                  <span className={styles.muted}>{note}</span>
                </div>
              ))}
            </div>
            <div className={styles.tip}>
              <Lightbulb size={24} weight="duotone" className={styles.icon} />
              <p>
                <strong>Piste pour la prochaine fois :</strong> termine par une
                phrase qui relie ton exemple au poste visé.
              </p>
            </div>
          </div>
        </section>

        <section className={styles.section}>
          <div className={styles.testimonialsHead}>
            <h6 className={styles.eyebrow}>Ils s’entraînent avec Waxtan</h6>
            <p className={styles.disclaimer}>
              <Info size={18} weight="duotone" />
              Témoignages fictifs, à titre d’exemple. Ils seront remplacés par de
              vrais retours d’utilisateurs.
            </p>
          </div>
          <div className={styles.testimonials}>
            {testimonials.map(({ quote, name, detail }) => (
              <figure key={name} className={`card ${styles.testimonial}`}>
                <span className="tag tag-neutral">Exemple fictif</span>
                <blockquote>« {quote} »</blockquote>
                <figcaption>
                  <strong>{name}</strong> · {detail}
                </figcaption>
              </figure>
            ))}
          </div>
        </section>

        <section className={styles.closing}>
          <InkBar large />
          <h2 className={styles.closingTitle}>
            Ton prochain entretien se prépare{" "}
            <span className={styles.accentItalic}>maintenant.</span>
          </h2>
          <p className={styles.closingLead}>
            Ta première session prend moins de 5 minutes. Tu en ressortiras avec
            au moins une chose à améliorer.
          </p>
          <div className={styles.cta}>
            <CtaButton />
            <span className={styles.muted}>Gratuit · Sans carte bancaire</span>
          </div>
        </section>
      </main>

      <footer className={styles.footer}>
        <div className={styles.footerTop}>
          <div className={styles.footerBrand}>
            <Wordmark />
            <span className={styles.tagline}>Ta voix, ton meilleur atout.</span>
          </div>
          <nav className={styles.footerNav}>
            {footerLinks.map(({ href, label }) => (
              <a key={label} href={href}>{label}</a>
            ))}
          </nav>
        </div>
        <div className={styles.legal}>
          <span>© 2026 waxtan.app</span>
          <span>Fait à Dakar, pour toute l’Afrique francophone</span>
          <span>Tes vidéos restent privées</span>
        </div>
      </footer>
    </div>
  );
}
