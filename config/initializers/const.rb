class Const
  CURRENCY = ['￥', '$', '€', '₽', '¥', '£', '₮'].freeze
  FREE_SHIPPING = 20000
  SHIPPING_FEE = 4000
  # буцаалт, солилт үнэ, үнийн зааг
  DISTRIBUTION = [2500, 20000, 3000, 3500, 4000, 6000, 4000, 3120]
  PRODUCT_NAME = ['Барааг шууд илэрхийлэх нэрийг оруулна.',
                  'Үйлдвэрээс өгсөн дахин давтагдахгүй моделийн дугаартай бол түүнийг оруулж өгнө.',
                  'Бүтээгдэхүүний хэмжээ, багцын мэдээлэл нь бүтээгдэхүүний гол мэдээллийн нэг гэж үзвэл оруулна. Жишээ нь тухайн бүтээгдэхүүн хайрцаг, савлагаандаа 10ш агуулагдсан, эсвэл 250мг хэмжээтэй энэ нь бүтээгдэхүүний гол мэдээллийн нэг бол оруулж өгнө.',
                  'Брэндийн бүтээгдэхүүн биш бол "Брэнд биш" сонголтыг сонгоно, брэндийн нэр жагсаалтад байхгүй бол тохиргоо хэсэгт брэндийг эхлээд үүсгэсний дараа брэндийг сонгож өгнө.',
                  'Тухайн барааны материал нь бүтээгдэхүүнийг илэрхийлэх гол мэдээллийн нэг гэж үзвэл оруулж өгнө.',
                  'Бүтээгдэхүүний талаарх бусад гол давуу талуудыг бичиж өгнө.'].freeze
  PRODUCT_INFO = ["“Хайлтын үг” талбарыг бичихдээ бүтээгдэхүүний нэр, дэлгэрэнгүй мэдээлэлд орсон үгийг дахин бичихгүй.
Брэндийн нэр, өнгө, хэмжээ зэрэг мэдээллийг вэб сайтын хайлтын систем автоматаар оруулах тул “хайлтын үг” талбарт бичихгүй
Бүтээгдэхүүнийг хамгийн сайн илэрхийлэх үгнүүдийг зай аваад бичнэ
Таслал, цэг авах шаардлагагүй, том жижиг үсгийг ялгахгүй тул аль ч хэлбэрээр бичсэн болно
Хэрэглэгчийн алдаатай болон өөр үгээр бичиж болох хувилбаруудыг оруулан бичнэ
Бүтээгдэхүүний нэр, бусад хайлтын үгнүүдийг латин цагаан толгойгоор галиглан бичиж өгнө.",
                  "Хамгийн чухал 3 гол санааг эхний 3 багц мөрөнд 250 тэмдэгтэд багтаана.
Барааны нэрэнд оруулсан гол мэдээллүүдийг шууд хуулах шаардлагагүй, барааны нэрэнд оруулсан гол мэдээллүүдээ дэлгэрүүлэн, дэмжих үгнүүд ашиглан бичнэ.
Хэрэглэгчийн хэрэгцээ, шаардлагатай мэдээлэл юу вэ? Гэдгийг бодож оруулахаас гадна хэрэглэгч заавал мэдэх, анхаарах ёстой мэдээллүүдийг оруулна.
Хүч нэмсэн, нийтлэг тэмдэг үг ашиглах шаардлагагүй. Ж нь: Маш, гоё г.м. Тухайн барааны онцлогийг харуулсан тэмдэг нэрийг ашиглахад болно. Ж нь: Хатуу, уян г.м
Барааны дэлгэрэнгүй мэдээлэлд зураг оруулж болдог байна.",
                  'Өнгө, хэмжээ нь ижил зурагтай бол адил шинж чанарыг сонгоно. Ж нь "Улаан - 37" "Улаан - 38" гутал нь нэг зургаар илэрхийлэгдэх тул "Улаан - 37" зургийг оруулж өгөөд "Улаан - 38"-ийн адил шинж чанар нүдэнд  "Улаан - 37" гэж сонгож өгнө.',
                  'Бүтээгдэхүүнийг угсарсны дараах хэрэглэгчид шаардагдах хэмжээсүүдийг оруулна. Ж нь: Гэрийн босоо турник угсарсны дараах урт, өргөн, өндөрийн мэдээлэл оруулах шаардлагатай',
                  'Гоо сайхны бараа, хүнс зэрэг хадгалах хугацаа заасан бүтээгдэхүүний хугацааг оруулна',
                  'Хэрэглэх, угсрах, угаах заавартай бол оруулж өгнө',
                  'Тухайн бүтээгдэхүүнд хамаарах үзүүлэлтийг заавал бөглөнө',
                  'Үйлдвэрлэсэн улсыг заавал бөглөнө'].freeze
  PRODUCT_IMG = ['Дөрвөлжин, ар тал нь цагаан зураг оруулна',
                 'Өнгө, хэмжээнээс хамаараад харагдах хэлбэр өөр бол зургийг тус бүрийн зургийг оруулна',
                 '"Нүүр зураг", "өнгө хэмжээний зураг"-т орсон зургийг дахиж оруулахгүйгээр бусад зургийг оруулна',
                 'Бүтээгдэхүүний бодит зургийг заавал оруулна, бодит зургийг чанартай авч чадаагүй бол вэб-д харуулах товчийг сонгохгүй'].freeze
  PRODUCT_SIZE = ['Хайрцаг, ууттай үеийн урт, өргөн, өндөрийг оруулна',
                  'Бүтээгдэхүүний хайрцаг, боодолтой үеийн жинг оруулна',
                  'Тухайн бүтээгдэхүүн 53*29*37 ба түүнээс бага хэмжээтэй бол бэлгийн боолт хийх боломжтой байна. Харилцагчийн барааг харилцагчийн агуулахаас хүргэлт хийх нөхцөлтэй бол бэлгийн боолт хийх боломжгүй'].freeze
end
