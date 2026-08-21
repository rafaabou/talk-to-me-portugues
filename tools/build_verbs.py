#!/usr/bin/env python3
"""Generate app/assets/course/verbs.json: a curated conjugation dataset.

~50 common Brazilian Portuguese verbs x 6 tenses x 6 persons, with
PT/EN/AR tense labels. Regular verbs are conjugated by rule; irregular
verbs carry explicit tables. Idempotent.

Usage: python3 build_verbs.py [out_path]
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
    ROOT, "..", "app", "assets", "course", "verbs.json")

TENSES = {
    "present":    {"pt": "Presente",            "en": "Present",          "ar": "المضارع"},
    "preterite":  {"pt": "Pretérito Perfeito",  "en": "Preterite (Past)", "ar": "الماضي البسيط"},
    "imperfect":  {"pt": "Pretérito Imperfeito","en": "Imperfect",        "ar": "الماضي المستمر"},
    "future":     {"pt": "Futuro",              "en": "Future",           "ar": "المستقبل"},
    "conditional":{"pt": "Condicional",         "en": "Conditional",      "ar": "الشرطي"},
    "subjunctive":{"pt": "Subjuntivo Presente", "en": "Subjunctive",      "ar": "المضارع المنصوب"},
}
PERSONS = ["eu", "você", "ele/ela", "nós", "vocês", "eles/elas"]


def ar(stem, sfx):
    return [stem + s for s in sfx]


def er(stem, sfx):
    return [stem + s for s in sfx]


def ir(stem, sfx):
    return [stem + s for s in sfx]


def regular(verb_class, stem):
    """Return dict of 6 tenses as lists for a regular verb."""
    if verb_class == "ar":
        # -car/-gar verbs need -qu-/-gu- before -e (fiquei, paguei)
        is_cg = stem.endswith("c") or stem.endswith("g")
        pret_e = stem + ("uei" if is_cg else "ei")
        subj = ("ue", "ue", "ue", "uemos", "uem", "uem") if is_cg \
            else ("e", "e", "e", "emos", "em", "em")
        return {
            "present":     ar(stem, ["o", "a", "a", "amos", "am", "am"]),
            "preterite":   [pret_e] + ar(stem, ["ou", "ou", "amos", "aram", "aram"]),
            "imperfect":   ar(stem, ["ava", "ava", "ava", "ávamos", "avam", "avam"]),
            "future":      ar(stem, ["arei", "ará", "ará", "aremos", "arão", "arão"]),
            "conditional": ar(stem, ["aria", "aria", "aria", "aríamos", "ariam", "ariam"]),
            "subjunctive": ar(stem, list(subj)),
        }
    if verb_class == "er":
        return {
            "present":     er(stem, ["o", "e", "e", "emos", "em", "em"]),
            "preterite":   er(stem, ["i", "eu", "eu", "emos", "eram", "eram"]),
            "imperfect":   er(stem, ["ia", "ia", "ia", "íamos", "iam", "iam"]),
            "future":      er(stem, ["erei", "erá", "erá", "eremos", "erão", "erão"]),
            "conditional": er(stem, ["eria", "eria", "eria", "eríamos", "eriam", "eriam"]),
            "subjunctive": er(stem, ["a", "a", "a", "amos", "am", "am"]),
        }
    # ir-class
    return {
        "present":     ir(stem, ["o", "e", "e", "imos", "em", "em"]),
        "preterite":   ir(stem, ["i", "iu", "iu", "imos", "iram", "iram"]),
        "imperfect":   ir(stem, ["ia", "ia", "ia", "íamos", "iam", "iam"]),
        "future":      ir(stem, ["irei", "irá", "irá", "iremos", "irão", "irão"]),
        "conditional": ir(stem, ["iria", "iria", "iria", "iríamos", "iriam", "iriam"]),
        "subjunctive": ir(stem, ["a", "a", "a", "amos", "am", "am"]),
    }


VERBS = [
    # irregular: (infinitive, en, ar, tables)
    ("ser", "to be", "يكون", {
        "present":     ["sou", "é", "é", "somos", "são", "são"],
        "preterite":   ["fui", "foi", "foi", "fomos", "foram", "foram"],
        "imperfect":   ["era", "era", "era", "éramos", "eram", "eram"],
        "future":      ["serei", "será", "será", "seremos", "serão", "serão"],
        "conditional": ["seria", "seria", "seria", "seríamos", "seriam", "seriam"],
        "subjunctive": ["seja", "seja", "seja", "sejamos", "sejam", "sejam"],
    }),
    ("estar", "to be (temporary)", "يكون (حالة)", {
        "present":     ["estou", "está", "está", "estamos", "estão", "estão"],
        "preterite":   ["estive", "esteve", "esteve", "estivemos", "estiveram", "estiveram"],
        "imperfect":   ["estava", "estava", "estava", "estávamos", "estavam", "estavam"],
        "future":      ["estarei", "estará", "estará", "estaremos", "estarão", "estarão"],
        "conditional": ["estaria", "estaria", "estaria", "estaríamos", "estariam", "estariam"],
        "subjunctive": ["esteja", "esteja", "esteja", "estejamos", "estejam", "estejam"],
    }),
    ("ter", "to have", "يملك", {
        "present":     ["tenho", "tem", "tem", "temos", "têm", "têm"],
        "preterite":   ["tive", "teve", "teve", "tivemos", "tiveram", "tiveram"],
        "imperfect":   ["tinha", "tinha", "tinha", "tínhamos", "tinham", "tinham"],
        "future":      ["terei", "terá", "terá", "teremos", "terão", "terão"],
        "conditional": ["teria", "teria", "teria", "teríamos", "teriam", "teriam"],
        "subjunctive": ["tenha", "tenha", "tenha", "tenhamos", "tenham", "tenham"],
    }),
    ("fazer", "to do / make", "يفعل / يصنع", {
        "present":     ["faço", "faz", "faz", "fazemos", "fazem", "fazem"],
        "preterite":   ["fiz", "fez", "fez", "fizemos", "fizeram", "fizeram"],
        "imperfect":   ["fazia", "fazia", "fazia", "fazíamos", "faziam", "faziam"],
        "future":      ["farei", "fará", "fará", "faremos", "farão", "farão"],
        "conditional": ["faria", "faria", "faria", "faríamos", "fariam", "fariam"],
        "subjunctive": ["faça", "faça", "faça", "façamos", "façam", "façam"],
    }),
    ("ir", "to go", "يذهب", {
        "present":     ["vou", "vai", "vai", "vamos", "vão", "vão"],
        "preterite":   ["fui", "foi", "foi", "fomos", "foram", "foram"],
        "imperfect":   ["ia", "ia", "ia", "íamos", "iam", "iam"],
        "future":      ["irei", "irá", "irá", "iremos", "irão", "irão"],
        "conditional": ["iria", "iria", "iria", "iríamos", "iriam", "iriam"],
        "subjunctive": ["vá", "vá", "vá", "vamos", "vão", "vão"],
    }),
    ("vir", "to come", "يأتي", {
        "present":     ["venho", "vem", "vem", "vimos", "vêm", "vêm"],
        "preterite":   ["vim", "veio", "veio", "viemos", "vieram", "vieram"],
        "imperfect":   ["vinha", "vinha", "vinha", "vínhamos", "vinham", "vinham"],
        "future":      ["virei", "virá", "virá", "viremos", "virão", "virão"],
        "conditional": ["viria", "viria", "viria", "viríamos", "viriam", "viriam"],
        "subjunctive": ["venha", "venha", "venha", "venhamos", "venham", "venham"],
    }),
    ("dizer", "to say", "يقول", {
        "present":     ["digo", "diz", "diz", "dizemos", "dizem", "dizem"],
        "preterite":   ["disse", "disse", "disse", "dissemos", "disseram", "disseram"],
        "imperfect":   ["dizia", "dizia", "dizia", "dizíamos", "diziam", "diziam"],
        "future":      ["direi", "dirá", "dirá", "diremos", "dirão", "dirão"],
        "conditional": ["diria", "diria", "diria", "diríamos", "diriam", "diriam"],
        "subjunctive": ["diga", "diga", "diga", "digamos", "digam", "digam"],
    }),
    ("saber", "to know (facts)", "يعرف", {
        "present":     ["sei", "sabe", "sabe", "sabemos", "sabem", "sabem"],
        "preterite":   ["soube", "soube", "soube", "soubemos", "souberam", "souberam"],
        "imperfect":   ["sabia", "sabia", "sabia", "sabíamos", "sabiam", "sabiam"],
        "future":      ["saberei", "saberá", "saberá", "saberemos", "saberão", "saberão"],
        "conditional": ["saberia", "saberia", "saberia", "saberíamos", "saberiam", "saberiam"],
        "subjunctive": ["saiba", "saiba", "saiba", "saibamos", "saibam", "saibam"],
    }),
    ("poder", "to be able to", "يستطيع", {
        "present":     ["posso", "pode", "pode", "podemos", "podem", "podem"],
        "preterite":   ["pude", "pôde", "pôde", "pudemos", "puderam", "puderam"],
        "imperfect":   ["podia", "podia", "podia", "podíamos", "podiam", "podiam"],
        "future":      ["poderei", "poderá", "poderá", "poderemos", "poderão", "poderão"],
        "conditional": ["poderia", "poderia", "poderia", "poderíamos", "poderiam", "poderiam"],
        "subjunctive": ["possa", "possa", "possa", "possamos", "possam", "possam"],
    }),
    ("querer", "to want", "يريد", {
        "present":     ["quero", "quer", "quer", "queremos", "querem", "querem"],
        "preterite":   ["quis", "quis", "quis", "quisemos", "quiseram", "quiseram"],
        "imperfect":   ["queria", "queria", "queria", "queríamos", "queriam", "queriam"],
        "future":      ["quererei", "quererá", "quererá", "quereremos", "quererão", "quererão"],
        "conditional": ["quereria", "quereria", "quereria", "quereríamos", "quereriam", "quereriam"],
        "subjunctive": ["queira", "queira", "queira", "queiramos", "queiram", "queiram"],
    }),
    ("haver", "there to be", "يوجد", {
        "present":     ["há", "há", "há", "há", "há", "há"],
        "preterite":   ["houve", "houve", "houve", "houve", "houve", "houve"],
        "imperfect":   ["havia", "havia", "havia", "havia", "havia", "havia"],
        "future":      ["haverá", "haverá", "haverá", "haverá", "haverá", "haverá"],
        "conditional": ["haveria", "haveria", "haveria", "haveria", "haveria", "haveria"],
        "subjunctive": ["haja", "haja", "haja", "haja", "haja", "haja"],
    }),
    ("ver", "to see", "يرى", {
        "present":     ["vejo", "vê", "vê", "vemos", "veem", "veem"],
        "preterite":   ["vi", "viu", "viu", "vimos", "viram", "viram"],
        "imperfect":   ["via", "via", "via", "víamos", "viam", "viam"],
        "future":      ["verei", "verá", "verá", "veremos", "verão", "verão"],
        "conditional": ["veria", "veria", "veria", "veríamos", "veriam", "veriam"],
        "subjunctive": ["veja", "veja", "veja", "vejamos", "vejam", "vejam"],
    }),
    ("dar", "to give", "يعطي", {
        "present":     ["dou", "dá", "dá", "damos", "dão", "dão"],
        "preterite":   ["dei", "deu", "deu", "demos", "deram", "deram"],
        "imperfect":   ["dava", "dava", "dava", "dávamos", "davam", "davam"],
        "future":      ["darei", "dará", "dará", "daremos", "darão", "darão"],
        "conditional": ["daria", "daria", "daria", "daríamos", "dariam", "dariam"],
        "subjunctive": ["dê", "dê", "dê", "demos", "deem", "deem"],
    }),
    ("pôr", "to put", "يضع", {
        "present":     ["ponho", "põe", "põe", "pomos", "põem", "põem"],
        "preterite":   ["pus", "pôs", "pôs", "pusemos", "puseram", "puseram"],
        "imperfect":   ["punha", "punha", "punha", "púnhamos", "punham", "punham"],
        "future":      ["porei", "porá", "porá", "poremos", "porão", "porão"],
        "conditional": ["poria", "poria", "poria", "poríamos", "poriam", "poriam"],
        "subjunctive": ["ponha", "ponha", "ponha", "ponhamos", "ponham", "ponham"],
    }),
    ("ficar", "to stay / become", "يبقى / يصبح", None),
    ("viver", "to live", "يعيش", None),
    ("morar", "to live (somewhere)", "يسكن", None),
    ("trabalhar", "to work", "يعمل", None),
    ("comprar", "to buy", "يشتري", None),
    ("vender", "to sell", "يبيع", None),
    ("beber", "to drink", "يشرب", None),
    ("comer", "to eat", "يأكل", None),
    ("falar", "to speak", "يتكلم", None),
    ("entender", "to understand", "يفهم", None),
    ("aprender", "to learn", "يتعلم", None),
    ("ler", "to read", "يقرأ", None),
    ("escrever", "to write", "يكتب", None),
    ("gostar", "to like", "يحب", None),
    ("precisar", "to need", "يحتاج", None),
    ("encontrar", "to find / meet", "يجد", None),
    ("abrir", "to open", "يفتح", None),
    ("fechar", "to close", "يغلق", None),
    ("pensar", "to think", "يفكر", None),
    ("achar", "to think / find", "يظن", None),
    ("chamar", "to call", "ينادي", None),
    ("chegar", "to arrive", "يصل", None),
    ("sair", "to leave", "يخرج", None),
    ("voltar", "to return", "يعود", None),
    ("levar", "to take / carry", "يأخذ", None),
    ("trazer", "to bring", "يجلب", None),
    ("andar", "to walk", "يمشي", None),
    ("correr", "to run", "يجري", None),
    ("dormir", "to sleep", "ينام", None),
    ("acordar", "to wake up", "يستيقظ", None),
    ("pagar", "to pay", "يدفع", None),
    ("esperar", "to wait / hope", "ينتظر", None),
    ("sentir", "to feel", "يشعر", None),
    ("olhar", "to look", "ينظر", None),
    ("ouvir", "to hear / listen", "يسمع", None),
    ("assistir", "to watch / attend", "يشاهد", None),
]

# semi-irregular verbs: explicit tables
SEMI = {
    "sair": {
        "present":     ["saio", "sai", "sai", "saímos", "saem", "saem"],
        "preterite":   ["saí", "saiu", "saiu", "saímos", "saíram", "saíram"],
        "imperfect":   ["saía", "saía", "saía", "saíamos", "saíam", "saíam"],
        "future":      ["sairei", "sairá", "sairá", "sairemos", "sairão", "sairão"],
        "conditional": ["sairia", "sairia", "sairia", "sairíamos", "sairiam", "sairiam"],
        "subjunctive": ["saia", "saia", "saia", "saiamos", "saiam", "saiam"],
    },
    "dormir": {
        "present":     ["durmo", "dorme", "dorme", "dormimos", "dormem", "dormem"],
        "preterite":   ["dormi", "dormiu", "dormiu", "dormimos", "dormiram", "dormiram"],
        "imperfect":   ["dormia", "dormia", "dormia", "dormíamos", "dormiam", "dormiam"],
        "future":      ["dormirei", "dormirá", "dormirá", "dormiremos", "dormirão", "dormirão"],
        "conditional": ["dormiria", "dormiria", "dormiria", "dormiríamos", "dormiriam", "dormiriam"],
        "subjunctive": ["durma", "durma", "durma", "durmamos", "durma", "durmam"],
    },
    "sentir": {
        "present":     ["sinto", "sente", "sente", "sentimos", "sentem", "sentem"],
        "preterite":   ["senti", "sentiu", "sentiu", "sentimos", "sentiram", "sentiram"],
        "imperfect":   ["sentia", "sentia", "sentia", "sentíamos", "sentiam", "sentiam"],
        "future":      ["sentirei", "sentirá", "sentirá", "sentiremos", "sentirão", "sentirão"],
        "conditional": ["sentiria", "sentiria", "sentiria", "sentiríamos", "sentiriam", "sentiriam"],
        "subjunctive": ["sinta", "sinta", "sinta", "sintamos", "sinta", "sintam"],
    },
    "ouvir": {
        "present":     ["ouço", "ouve", "ouve", "ouvimos", "ouvem", "ouvem"],
        "preterite":   ["ouvi", "ouviu", "ouviu", "ouvimos", "ouviram", "ouviram"],
        "imperfect":   ["ouvia", "ouvia", "ouvia", "ouvíamos", "ouviam", "ouviam"],
        "future":      ["ouvirei", "ouvirá", "ouvirá", "ouviremos", "ouvirão", "ouvirão"],
        "conditional": ["ouviria", "ouviria", "ouviria", "ouviríamos", "ouviriam", "ouviriam"],
        "subjunctive": ["ouça", "ouça", "ouça", "ouçamos", "ouça", "ouçam"],
    },
    "trazer": {
        "present":     ["trago", "traz", "traz", "trazemos", "trazem", "trazem"],
        "preterite":   ["trouxe", "trouxe", "trouxe", "trouxemos", "trouxeram", "trouxeram"],
        "imperfect":   ["trazia", "trazia", "trazia", "trazíamos", "traziam", "traziam"],
        "future":      ["trarei", "trará", "trará", "traremos", "trarão", "trarão"],
        "conditional": ["traria", "traria", "traria", "traríamos", "trariam", "trariam"],
        "subjunctive": ["traga", "traga", "traga", "tragamos", "traga", "tragam"],
    },
    "ler": {
        "present":     ["leio", "lê", "lê", "lemos", "leem", "leem"],
        "preterite":   ["li", "leu", "leu", "lemos", "leram", "leram"],
        "imperfect":   ["lia", "lia", "lia", "líamos", "liam", "liam"],
        "future":      ["lerei", "lerá", "lerá", "leremos", "lerão", "lerão"],
        "conditional": ["leria", "leria", "leria", "leríamos", "leriam", "leriam"],
        "subjunctive": ["leia", "leia", "leia", "leiamos", "leia", "leiam"],
    },
    "pagar": {
        "present":     ["pago", "paga", "paga", "pagamos", "pagam", "pagam"],
        "preterite":   ["paguei", "pagou", "pagou", "pagamos", "pagaram", "pagaram"],
        "imperfect":   ["pagava", "pagava", "pagava", "pagávamos", "pagavam", "pagavam"],
        "future":      ["pagarei", "pagará", "pagará", "pagaremos", "pagarão", "pagarão"],
        "conditional": ["pagaria", "pagaria", "pagaria", "pagaríamos", "pagariam", "pagariam"],
        "subjunctive": ["pague", "pague", "pague", "paguemos", "pague", "paguem"],
    },
    "chegar": {
        "present":     ["chego", "chega", "chega", "chegamos", "chegam", "chegam"],
        "preterite":   ["cheguei", "chegou", "chegou", "chegamos", "chegaram", "chegaram"],
        "imperfect":   ["chegava", "chegava", "chegava", "chegávamos", "chegavam", "chegavam"],
        "future":      ["chegarei", "chegará", "chegará", "chegaremos", "chegarão", "chegarão"],
        "conditional": ["chegaria", "chegaria", "chegaria", "chegaríamos", "chegariam", "chegariam"],
        "subjunctive": ["chegue", "chegue", "chegue", "cheguemos", "chegue", "cheguem"],
    },
    "achar": {
        "present":     ["acho", "acha", "acha", "achamos", "acham", "acham"],
        "preterite":   ["achei", "achou", "achou", "achamos", "acharam", "acharam"],
        "imperfect":   ["achava", "achava", "achava", "achávamos", "achavam", "achavam"],
        "future":      ["acharei", "achará", "achará", "acharemos", "acharão", "acharão"],
        "conditional": ["acharia", "acharia", "acharia", "acharíamos", "achariam", "achariam"],
        "subjunctive": ["ache", "ache", "ache", "achemos", "ache", "achem"],
    },
    "ficar": {
        "present":     ["fico", "fica", "fica", "ficamos", "ficam", "ficam"],
        "preterite":   ["fiquei", "ficou", "ficou", "ficamos", "ficaram", "ficaram"],
        "imperfect":   ["ficava", "ficava", "ficava", "ficávamos", "ficavam", "ficavam"],
        "future":      ["ficarei", "ficará", "ficará", "ficaremos", "ficarão", "ficarão"],
        "conditional": ["ficaria", "ficaria", "ficaria", "ficaríamos", "ficariam", "ficariam"],
        "subjunctive": ["fique", "fique", "fique", "fiquemos", "fique", "fiquem"],
    },
}

# stems for regular verbs
REGULAR = {
    "viver":     ("er", "viv"),
    "morar":     ("ar", "mor"),
    "trabalhar": ("ar", "trabalh"),
    "comprar":   ("ar", "compr"),
    "vender":    ("er", "vend"),
    "beber":     ("er", "beb"),
    "comer":     ("er", "com"),
    "falar":     ("ar", "fal"),
    "entender":  ("er", "entend"),
    "aprender":  ("er", "aprend"),
    "escrever":  ("er", "escrev"),
    "gostar":    ("ar", "gost"),
    "precisar":  ("ar", "precis"),
    "encontrar": ("ar", "encontr"),
    "abrir":     ("ir", "abr"),
    "fechar":    ("ar", "fech"),
    "pensar":    ("ar", "pens"),
    "chamar":    ("ar", "cham"),
    "voltar":    ("ar", "volt"),
    "levar":     ("ar", "lev"),
    "andar":     ("ar", "and"),
    "correr":    ("er", "corr"),
    "acordar":   ("ar", "acord"),
    "esperar":   ("ar", "esper"),
    "olhar":     ("ar", "olh"),
    "assistir":  ("ir", "assist"),
}


def main():
    verbs_out = []
    for inf, en, ar, tables in VERBS:
        if tables is None:
            if inf in SEMI:
                tables = SEMI[inf]
            else:
                cls, stem = REGULAR[inf]
                tables = regular(cls, stem)
        # sanity: every tense has 6 forms
        assert all(len(tables[t]) == 6 for t in TENSES), inf
        verbs_out.append({
            "inf": inf,
            "en": en,
            "ar": ar,
            **tables,
        })

    data = {
        "tenses": TENSES,
        "persons": PERSONS,
        "verbs": verbs_out,
    }
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(data, fh, ensure_ascii=False, indent=2)
    print(f"Wrote {len(verbs_out)} verbs to {OUT}")


if __name__ == "__main__":
    main()