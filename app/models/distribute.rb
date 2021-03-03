class Distribute
  include Singleton

  def create(salesman)

    return_signs = SalesmanReturnSign.by_salesman(salesman.id)
                       .by_user(nil)
    if return_signs.present?
      [422, I18n.t('errors.messages.return_request_not_confirmed')]
    else
      sale_items = ProductSaleItem.sale_available(salesman.id)
      if sale_items.present?
        [422, I18n.t('errors.messages.you_have_a_balance')]
      else

        product_sales = ProductSale.by_salesman_nil

        location_ids = product_sales.map(&:location_id).to_a
        if location_ids.length == 0
          [422, I18n.t('errors.messages.not_have_a_product_sale')]
        else
          location_ids.unshift(1) # Агуулахаас эхлэнэ
          # [1, 2687, 3727, 3, 16, 7, 2823]

          locations = Location.search_by_ids(location_ids)
          # location_travels = save_travels(locations)
          location_travel_ids = [3255, 3256, 3257, 3258, 3259, 3260, 3261, 3262, 3263, 3264, 2916, 3265, 3266, 2919, 1209, 3267, 3268, 2014, 3269, 3270, 3271, 3272, 3273, 3274, 3275, 3276, 3277, 3278, 3279, 3280, 3281, 3282, 3283, 3284, 3285, 3286, 3287, 3288, 3289, 3290, 3291, 3292, 3293, 3294, 3295, 3296, 3297, 3298, 3299, 3300, 3301, 3302, 3303, 3304, 3305, 3306, 3307, 3308, 3309, 3310, 3311, 3312, 3313, 3314, 3315, 3316, 3317, 3318, 3319, 3320, 3321, 3322, 3323, 3324, 3325, 3326, 3327, 3328, 3329, 3330, 3331, 3332, 3333, 3334, 3335, 3336, 3337, 3338, 3339, 3340, 3341, 3342, 3343, 3344, 3345, 3346, 3347, 3348, 1375, 698, 2923, 3349, 3350, 3351, 3352, 3353, 2924, 3354, 3355, 3356, 2926, 2927, 3357, 3358, 2928, 2929, 3359, 3360, 3361, 3362, 3363, 3364, 3365, 3366, 3367, 3368, 3369, 3370, 3371, 3372, 3373, 3374, 3375, 3376, 3377, 3378, 3379, 3380, 3381, 3382, 3383, 3384, 3385, 3386, 3387, 3388, 3389, 3390, 3391, 3392, 3393, 3394, 3395, 3396, 3397, 3398, 3399, 3400, 3401, 3402, 3403, 3404, 3405, 3406, 3407, 3408, 3409, 3410, 3411, 3412, 3413, 3414, 3415, 3416, 3417, 3418, 3419, 3420, 3421, 3422, 3423, 3424, 3425, 3426, 3427, 3428, 3429, 3430, 3431, 3432, 3433, 3434, 3435, 3436, 3437, 3438, 3439, 3440, 3441, 3442, 3443, 3444, 3445, 3446, 3447, 3448, 3449, 3450, 3451, 3452, 3453, 3454, 3455, 3456, 3457, 3458, 3459, 3460, 3461, 3462, 3463, 3464, 3465, 3466, 3467, 3468, 3469, 3470, 3471, 3472, 3473, 3474, 3475, 3476, 3477, 3478, 3479, 3480, 3481, 3482, 3483, 3484, 3485, 3486, 3487, 3488, 3489, 3490, 3491, 3492, 3493, 3494, 3495, 3496, 3497, 3498, 3499, 3500, 3501, 3502, 3503, 3504, 3505, 3506, 3507, 3508, 3509, 3510, 3511, 3512, 3513, 3514, 3515, 3516, 3517, 3518, 3519, 3520, 3521, 3522, 3523, 3524, 3525, 3526, 3527, 3528, 3529, 3530, 3531, 3532, 3533, 3534, 3535, 3536, 3537, 3538, 3539, 3540, 3541, 3542, 3543, 3544, 3545, 3546, 3547, 3548, 3549, 3550, 3551, 3552, 3553, 3554, 3555, 3556, 3557, 3558, 3559, 3560, 3561, 3562, 3563, 3564, 3565, 3566, 3567, 3568, 3569, 3570, 3571, 3572, 3573, 3574, 3575, 3576, 3577, 3578, 3579, 3580, 3581, 3582, 3583, 3584, 3585, 3586, 3587, 3588, 3589, 3590, 3591, 3592, 3593, 3594, 3595, 3596, 3597, 3598, 3599, 3600, 3601, 3602, 3603, 3604, 3605, 3606, 3607, 3608, 3609, 3610, 3611, 3612, 3613, 3614, 3615, 3616, 3617, 3618, 3619, 3620, 3621, 3622, 3623, 3624, 3625, 3626, 3627, 3628, 3629, 3630, 3631, 3632, 3633, 3634, 3635, 3636, 3637, 3638, 3639, 3640, 3641, 3642, 3643, 3644, 3645, 3646, 3647, 3648, 3649, 3650, 3651, 3652, 3653, 3654, 3655, 3656, 3657, 3658, 3659, 3660, 3661, 3662, 3663, 3664, 3665, 3666, 3667, 3668, 3669, 3670, 3671, 3672, 3673, 3674, 2985, 3675, 3676, 3677, 3678, 3679, 3680, 3681, 3682, 3683, 3684, 3685, 3686, 2991, 3687, 3688, 3689, 3690, 3691, 3692, 3693, 3694, 3695, 3696, 3697, 3698, 3699, 3700, 3701, 3702, 3703, 3704, 3705, 3706, 3707, 3708, 3709, 3710, 3711, 3712, 3713, 3714, 3715, 3716, 3717, 3718, 3719, 3720, 3721, 3722, 3723, 3724, 3725, 3726, 3727, 3728, 3729, 3730, 3731, 3732, 3733, 3734, 3735, 3736, 3737, 3738, 3739, 3740, 3741, 3742, 3743, 3744, 3745, 3746, 3747, 3748, 3749, 3750, 3751, 3752, 3753, 3754, 3755, 3756, 3757, 3758, 3759, 3760, 3761, 3762, 3763, 2995, 3764, 3765, 3766, 3767, 3768, 2996, 3769, 3770, 3771, 2998, 2999, 3772, 3773, 3000, 3001, 3774, 3775, 3776, 3777, 3778, 3779, 3780, 3781, 3782, 3783, 3784, 3785, 3786, 3787, 3788, 3789, 3790, 3791, 3792, 3793, 3794, 3795, 3796, 3797, 3798, 3799, 3800, 3801, 3802, 3803, 3804, 3805, 3806, 3807, 3808, 3809, 3810, 3811, 3812, 3813, 3814, 3815, 3816, 3817, 3818, 3819, 3820, 3821, 3822, 3039, 3823, 3824, 3825, 3826, 3827, 3828, 3829, 3830, 3831, 3832, 3043, 3833, 3834, 3835, 3836, 3837, 3838, 3839, 3840, 3841, 3842, 3843, 3844, 1255, 3845, 3846, 3847, 3848, 3849, 3850, 3851, 3852, 3853, 3854, 3855, 3856, 3857, 3858, 3859, 3860, 3861, 3862, 3863, 3864, 3865, 3866, 3867, 3868, 3869, 3870, 3871, 3872, 3873, 3874, 3875, 3876, 3877, 3878, 3879, 3880, 3881, 3882, 3883, 3884, 3885, 3886, 3887, 3888, 3889, 3890, 3891, 3892, 3893, 3894, 3895, 3896, 3897, 3898, 3899, 3900, 3901, 3902, 3903, 3904, 3905, 3906, 3907, 3908, 3909, 3910, 3911, 3912, 3913, 3049, 3914, 3915, 3916, 3917, 3918, 3050, 3919, 3920, 3921, 3052, 3053, 3922, 3923, 3054, 3055, 3924, 3925, 3926, 3927, 3928, 3929, 3930, 3931, 3932, 3933, 3934, 3935, 3936, 3937, 3938, 3939, 3940, 3941, 3942, 3943, 3944, 3945, 3946, 3947, 3948, 3949, 3950, 3951, 3952, 3953, 3954, 3955, 3956, 3957, 3958, 3959, 3960, 3961, 3962, 3963, 3964, 3965, 3966, 3967, 3968, 3969, 3970, 3971, 3972, 3973, 3974, 3975, 3976, 3977, 3978, 3979, 3980, 3981, 3982, 3983, 3984, 3985, 3986, 3987, 3988, 3989, 3990, 3991, 3992, 3993, 2123, 3994, 3995, 3996, 3997, 3998, 3999, 4000, 4001, 4002, 4003, 4004, 4005, 4006, 4007, 4008, 4009, 4010, 4011, 4012, 4013, 4014, 4015, 4016, 4017, 4018, 4019, 4020, 4021, 4022, 4023, 4024, 4025, 4026, 4027, 4028, 4029, 4030, 4031, 4032, 4033, 4034, 4035, 4036, 4037, 4038, 4039, 4040, 4041, 4042, 4043, 4044, 4045, 4046, 4047, 4048, 4049, 4050, 4051, 4052, 4053, 4054, 4055, 4056, 4057, 4058, 4059, 4060, 4061, 4062, 4063, 4064, 4065, 4066, 4067, 4068, 4069, 4070, 4071, 4072, 4073, 4074, 4075, 4076, 4077, 4078, 4079, 4080, 4081, 4082, 4083, 4084, 4085, 4086, 4087, 4088, 4089, 4090, 4091, 4092, 4093, 4094, 4095, 4096, 4097, 4098, 4099, 4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109, 4110, 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119, 4120, 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129, 4130, 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139, 4140, 4141, 4142, 4143, 4144, 4145, 4146, 4147, 4148, 4149, 4150, 4151, 4152, 4153, 4154, 4155, 4156, 4157, 4158, 4159, 4160, 4161, 4162, 4163, 4164, 4165, 4166, 4167, 4168, 4169, 4170, 4171, 4172, 4173, 4174, 4175, 4176, 4177, 4178, 4179, 4180, 4181, 4182, 4183, 4184, 4185, 4186, 4187, 4188, 4189, 4190, 4191, 4192, 4193, 4194, 4195, 4196, 4197, 4198, 4199, 4200, 4201, 4202, 4203, 4204, 4205, 4206, 4207, 4208, 4209, 4210, 4211, 4212, 4213, 4214, 4215, 4216, 4217, 4218, 4219, 4220, 4221, 4222, 4223, 4224, 4225, 4226, 4227, 4228, 4229, 4230, 4231, 4232, 4233, 4234, 4235, 4236, 4237, 4238, 4239, 4240, 4241, 4242, 4243, 4244, 4245, 4246, 4247, 4248, 4249, 4250, 4251, 4252, 4253, 4254, 4255, 4256, 4257, 4258, 4259, 4260, 4261, 4262, 4263, 4264, 4265, 4266, 4267, 4268, 4269, 4270, 4271, 4272, 4273, 4274, 4275, 4276, 4277, 4278, 4279, 4280, 4281, 4282, 4283, 4284, 4285, 4286, 4287, 4288, 4289, 4290, 4291, 4292, 4293, 4294, 4295, 4296, 4297, 4298, 4299, 4300, 4301, 4302, 4303, 4304, 4305, 4306, 4307, 4308, 4309, 4310, 4311, 4312, 4313, 4314, 4315, 4316, 4317, 4318, 4319, 4320, 4321, 4322, 4323, 4324, 4325, 4326, 4327, 4328, 4329, 4330, 4331, 4332, 4333, 4334, 4335, 4336, 4337, 4338, 4339, 4340, 4341, 4342, 4343, 4344, 4345, 4346, 4347, 4348, 4349, 4350, 4351, 4352, 4353, 4354, 4355, 4356, 4357, 4358, 4359, 4360, 4361, 4362, 4363, 4364, 4365, 4366, 4367, 4368, 4369, 4370, 4371, 4372, 4373, 4374, 4375, 4376, 4377, 4378, 1401, 4379, 4380, 4381, 4382, 4383, 4384, 4385, 4386, 4387, 4388, 4389, 4390, 4391, 4392, 4393, 4394, 4395, 4396, 4397, 4398, 4399, 4400, 4401, 4402, 4403, 4404, 4405, 4406, 4407, 4408, 4409, 4410, 4411, 4412, 4413, 4414, 4415, 4416, 4417, 4418, 4419, 4420, 4421, 4422, 4423, 4424, 4425, 4426, 4427, 4428, 4429, 4430, 4431, 4432, 4433, 4434, 4435, 4436, 4437, 4438, 4439, 4440, 4441, 4442, 4443, 4444, 4445, 4446, 4447, 4448, 4449, 4450, 4451, 4452, 4453, 4454, 4455, 4456, 4457, 4458, 4459, 4460, 4461, 4462, 4463, 4464, 4465, 4466, 4467, 4468, 4469, 4470, 4471, 4472, 4473, 4474, 4475, 4476, 4477, 4478, 4479, 4480, 4481, 4482, 4483, 701, 4484, 4485, 4486, 4487, 4488, 4489, 4490, 4491, 4492, 4493, 4494, 4495, 4496, 4497, 4498, 4499, 4500, 4501, 4502, 4503, 4504, 4505, 4506, 4507, 3111, 4508, 4509, 4510, 4511, 4512, 4513, 4514, 4515, 4516, 4517, 3115, 4518, 4519, 3118, 4520, 4521, 4522, 4523, 4524, 4525, 4526, 4527, 4528, 4529, 4530, 4531, 4532, 4533, 4534, 4535, 4536, 4537, 4538, 4539, 4540, 4541, 4542, 4543, 4544, 4545, 4546, 4547, 4548, 4549, 4550, 4551, 4552, 4553, 4554, 4555, 4556, 4557, 4558, 4559, 4560, 4561, 4562, 4563, 4564, 4565, 4566, 4567, 4568, 4569, 4570, 4571, 4572, 4573, 4574, 4575, 4576, 4577, 4578, 4579, 4580, 4581, 4582, 4583, 4584, 4585, 4586, 4587, 4588, 4589, 4590, 4591, 4592, 4593, 4594, 4595, 4596, 4597, 4598, 4599, 4600, 4601, 4602, 4603, 4604, 4605, 4606, 4607, 4608, 3122, 4609, 4610, 4611, 3124, 3125, 4612, 4613, 3126, 3127, 4614, 4615, 4616, 4617, 4618, 4619, 4620, 4621, 4622, 4623, 4624, 4625, 4626, 4627, 4628, 4629, 4630, 4631, 4632, 4633, 4634, 4635, 4636, 4637, 4638, 4639, 4640, 4641, 4642, 4643, 4644, 4645, 4646, 4647, 4648, 4649, 4650, 4651, 4652, 4653, 4654, 4655, 4656, 4657, 4658, 4659, 4660, 4661, 4662, 4663, 4664, 4665, 4666, 4667, 4668, 4669, 4670, 4671, 4672, 4673, 4674, 4675, 4676, 4677, 4678, 4679, 4680, 4681, 4682, 4683, 4684, 4685, 4686, 4687, 4688, 4689, 4690, 4691, 4692, 4693, 4694, 4695, 4696, 4697, 4698, 4699, 4700, 4701, 4702, 4703, 4704, 4705, 4706, 4707, 4708, 4709, 4710, 4711, 4712, 4713, 4714, 4715, 4716, 4717, 4718, 4719, 4720, 4721, 4722, 4723, 4724, 4725, 4726, 4727, 4728, 4729, 3129, 4730, 4731, 4732, 4733, 4734, 4735, 4736, 4737, 4738, 4739, 3133, 4740, 4741, 3136, 4742, 4743, 4744, 4745, 4746, 4747, 4748, 4749, 4750, 4751, 4752, 4753, 4754, 4755, 4756, 4757, 4758, 4759, 4760, 4761, 4762, 4763, 4764, 4765, 4766, 4767, 4768, 4769, 4770, 4771, 4772, 4773, 4774, 4775, 4776, 4777, 4778, 4779, 4780, 4781, 4782, 4783, 4784, 4785, 4786, 4787, 4788, 4789, 4790, 4791, 4792, 4793, 4794, 4795, 4796, 4797, 4798, 4799, 4800, 4801, 4802, 4803, 4804, 4805, 4806, 4807, 4808, 4809, 4810, 4811, 4812, 4813, 4814, 4815, 3140, 4816, 4817, 4818, 4819, 4820, 4821, 4822, 4823, 3142, 3143, 4824, 4825, 3144, 3145, 4826, 4827, 4828, 4829, 4830, 4831, 4832, 4833, 4834, 4835, 4836, 4837, 4838, 4839, 4840, 4841, 4842, 4843, 4844, 4845, 4846, 4847, 4848, 4849, 4850, 4851, 4852, 4853, 4854, 4855, 4856, 4857, 4858, 4859, 4860, 4861, 4862, 4863, 4864, 4865, 4866, 4867, 4868, 4869, 4870, 4871, 4872, 4873, 4874, 4875, 4876, 4877, 4878, 4879, 4880, 4881, 4882, 4883, 4884, 4885, 4886, 4887, 4888, 4889, 4890, 4891, 4892, 4893, 4894, 4895, 4896, 4897, 4898, 4899, 4900, 4901, 3165, 4902, 4903, 4904, 4905, 4906, 4907, 4908, 4909, 4910, 4911, 3169, 4912, 4913, 3172, 4914, 4915, 4916, 4917, 4918, 4919, 4920, 4921, 4922, 4923, 4924, 4925, 4926, 4927, 4928, 4929, 4930, 4931, 4932, 4933, 4934, 4935, 4936, 4937, 4938, 4939, 4940, 4941, 4942, 4943, 4944, 4945, 4946, 4947, 4948, 4949, 4950, 4951, 4952, 4953, 4954, 4955, 4956, 4957, 4958, 4959, 4960, 4961, 4962, 4963, 4964, 4965, 4966, 4967, 4968, 4969, 4970, 4971, 4972, 4973, 4974, 4975, 4976, 4977, 4978, 4979, 4980, 4981, 4982, 4983, 4984, 4985, 4986, 4987, 3176, 4988, 4989, 4990, 4991, 4992, 3177, 4993, 4994, 4995, 3179, 4996, 4997, 3180, 3181, 4998, 3183, 4999, 5000, 5001, 5002, 5003, 5004, 5005, 5006, 5007, 5008, 3187, 5009, 5010, 3190, 5011, 5012, 5013, 5014, 5015, 5016, 5017, 5018, 5019, 5020, 5021, 5022, 5023, 5024, 5025, 5026, 5027, 5028, 5029, 5030, 5031, 5032, 5033, 5034, 5035, 5036, 5037, 5038, 5039, 5040, 5041, 5042, 5043, 5044, 5045, 5046, 5047, 5048, 5049, 5050, 5051, 5052, 5053, 5054, 5055, 5056, 5057, 5058, 5059, 5060, 5061, 5062, 5063, 5064, 5065, 5066, 5067, 5068, 5069, 5070, 3201, 5071, 5072, 5073, 5074, 5075, 5076, 5077, 5078, 5079, 5080, 3205, 5081, 5082, 3208, 5083, 5084, 5085, 5086, 5087, 5088, 5089, 5090, 5091, 5092, 5093, 5094, 5095, 5096, 3194, 5097, 5098, 5099, 5100, 5101, 3195, 5102, 5103, 5104, 3197, 5105, 5106, 3198, 3199, 5107, 5108, 5109, 5110, 5111, 5112, 5113, 5114, 5115, 5116, 5117, 5118, 5119, 5120, 5121, 5122, 5123, 5124, 5125, 5126, 5127, 5128, 5129, 5130, 5131, 5132, 5133, 5134, 5135, 5136, 5137, 5138, 5139, 5140, 5141, 5142, 5143, 5144, 5145, 5146, 5147, 5148, 5149, 5150, 5151, 3212, 5152, 5153, 5154, 5155, 5156, 3213, 5157, 5158, 5159, 3215, 3216, 5160, 5161, 3217, 5162, 3219, 5163, 5164, 5165, 5166, 5167, 5168, 5169, 5170, 5171, 5172, 3223, 5173, 5174, 3226, 5175, 5176, 5177, 5178, 5179, 5180, 5181, 5182, 5183, 5184, 5185, 5186, 5187, 5188, 5189, 5190, 5191, 5192, 5193, 5194, 5195, 5196, 5197, 5198, 5199, 5200, 5201, 5202, 5203, 5204, 5205, 5206, 5207, 5208, 5209, 5210, 5211, 5212, 5213, 3230, 5214, 5215, 5216, 5217, 5218, 3231, 5219, 5220, 5221, 3233, 3234, 5222, 5223, 3235, 5224, 5225, 5226, 5227, 5228, 5229, 5230, 5231, 5232, 5233, 5234, 5235, 5236, 5237, 5238, 5239, 5240, 5241, 5242, 5243, 5244]
          Rails.logger.info("location_travel_ids==#{location_travel_ids.length}")
          location_travels = LocationTravel.by_ids(location_travel_ids)

          hash_location_travels = location_travels.map {|i| [i.location_from_id.to_s + "-" + i.location_to_id.to_s, i]}.to_h
          routing = vrptw(location_ids, hash_location_travels).map(&:to_i)
          Rails.logger.info("routing = #{routing}")
          # routing = [138, 0, 4, 3, 1, 5, 6, 2, 0].map(&:to_i)

          travel = SalesmanTravel.new
          travel.salesman = salesman
          travel.distance = routing[0]
          travel_duration = 0
          loc_from_id = 1
          routing.each_with_index {|r, i|
            if i > 1 && r > 0
              product_sale = product_sales[r - 1]
              location = product_sale.location
              location_travel = hash_location_travels[loc_from_id.to_s + '-' + location.id.to_s]
              loc_from_id = location.id

              travel_route = SalesmanTravelRoute.new
              travel_route.queue = i - 2
              travel_route.distance = location_travel.distance
              travel_route.duration = location_travel.duration
              travel_duration = travel_duration + location_travel.duration
              travel_route.salesman_travel = travel
              travel_route.location = location
              travel_route.product_sale = product_sale

              travel.salesman_travel_routes << travel_route
            end
          }
          travel.duration = travel_duration
          travel.save

          routing.each_with_index {|r, i|
            if i > 1 && r > 0
              product_sale = product_sales[r - 1]
              product_sale.update_column(:salesman_travel_id, travel.id)
            end
          }
          travel.send_notification

          [201, 'created', travel]
        end
      end
    end

  end
end


def vrptw(location_ids, hash_loc_travels) # return routing = [138, 0, 7, 4, 3, 1, 6, 10, 2, 9, 8, 5, 11, 0]
  # location_travels = LocationTravel.search(location_ids).map {|i| [i.location_from_id.to_s + "-" + i.location_to_id.to_s, i]}.to_h

  folder_path = "public/routing/"
  file_temp = "#{Time.zone.now.to_i}"
  file_name = "#{file_temp}_case.txt"
  File.open(folder_path + file_name, "w")

  location_ids.each {|r_key|
    row_text = ""
    location_ids.each {|key|
      if r_key == key
        row_text += "0, "
      else
        location_travel = hash_loc_travels[r_key.to_s + '-' + key.to_s]
        if location_travel.present?
          row_text += location_travel.duration.to_s + ", "
        else
          row_text += "0, "
        end
      end
    }
    File.open(folder_path + file_name, "a") do |line|
      line.puts row_text.slice(0, row_text.length - 2)
    end
  }

  system "cd " + folder_path + " && python tsp.py " + file_temp

  result_path = folder_path + "#{file_temp}_result.txt"

  second = 0
  until File.exists?(result_path) || second == 6
    sleep(1)
    second += 1
  end

  travel_config = TravelConfig.get_last
  max_travel = travel_config.max_travel

  result_data = if second == 6
                  "error"
                else
                  File.read(result_path)
                end

  Rails.logger.info("result_data = #{result_data}")
  if result_data == "error"
    routing = result_data
  else
    Rails.logger.info("salesman р үзээд батгахгүй бол 2 машинаас эхлэж явуулж үзнэ")
    # salesman р үзээд батгахгүй бол 2 машинаас эхлэж явуулж үзнэ
    routing = extra_result("tsp", max_travel, result_data)

    if routing.length == 0 # багтаагүй байна
      vehicle = 2
      while routing != "error" && routing.length == 0
        FileUtils.rm(result_path)
        system "cd " + folder_path + " && python vrp.py " + max_travel.to_s + " " + file_temp + " " + vehicle.to_s

        second = 0
        until File.exists?(result_path) || second == 6
          sleep(1)
          second += 1
        end

        result_data = if second == 6
                        "error"
                      else
                        File.read(result_path)
                      end

        if result_data == "error"
          routing = result_data
        else
          routing = extra_result("vrp", max_travel, result_data)
        end

        vehicle += 1 # машины тоог нэмж үзнэ
      end

    end
  end
  # TODO буцаах устгадаг болгох
  # FileUtils.rm [folder_path + file_name, result_path]

  routing
end

def extra_result(type, max_travel, result)
  if type == "tsp"
    array = result.split(',').map(&:to_i)
    if max_travel >= array[0]
      return array
    end

  else # vrp

    lines = result.split(/\n+/)
    min_max = lines[lines.length - 1].split(',').map(&:to_i)
    if max_travel >= min_max[0]
      max_routing = 0
      max_at_index = 0
      # олон хүргэлттэйг нь авна
      lines.each_with_index do |line, index|
        if index != lines.length - 1 # хамгийн сүүлийн мах мин учир тооцохгүй
          array = line.split(',').map(&:to_i)
          if max_travel >= array[1] && max_routing < array.length
            max_at_index = index
            max_routing = array.length
          end
        end
      end
      # олон хүргэлттэйг г олсон
      array = lines[max_at_index].split(',').map(&:to_i)
      return array.slice(1, array.length - 1)
    end

  end

  []
end

def save_travels(locations)
  # print ''
  # STDOUT.flush
  new_location_travels = []

  length = locations.length #locations.map(&:id).to_a
  # өмнө нь авсан зайнуудыг авна
  location_travels = LocationTravel.search(locations.map(&:id).to_a).map {|i| [i.location_from_id.to_s + "-" + i.location_to_id.to_s, i]}.to_h

  len_ori = 0 # google origins, destinations max 25 elements

  max_dis = length > 25 ? 25 : length
  max_ori = (100 / max_dis).to_i
  Rails.logger.info("distributing.max_ori = #{max_ori} / #{length}")
  Rails.logger.info("distributing.max_dis = #{max_dis} / #{length}")
  while len_ori < length do
    ori_locations = locations.slice(len_ori, max_ori)
    len_ori += ori_locations.length
    # Rails.logger.info("distributing.ori_locations = #{ori_locations.map(&:id).to_a}")
    # Rails.logger.info("distributing.len_ori = #{len_ori}")

    len_dis = 0
    while len_dis < length do
      dis_locations = locations.slice(len_dis, max_dis)
      len_dis += dis_locations.length
      # Rails.logger.info("distributing.len_dis = #{len_dis}")

      matrix_locations = []
      origins = ""
      destinations = ""

      ori_locations.each {|location|
        dis_locations.each {|loc_dis|
          matrix_locations.push([location.id, loc_dis.id])
        }
      }

      ori_locations.each {|location|
        if origins.length > 0
          origins += "|"
        end
        origins += location.latitude.to_s + "," + location.longitude.to_s
      }

      dis_locations.each {|location|
        if destinations.length > 0
          destinations += "|"
        end
        destinations += location.latitude.to_s + "," + location.longitude.to_s
      }

      # Rails.logger.debug("distributing.matrix_locations = #{matrix_locations.to_s}")

      url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=" + origins + "&destinations=" + destinations + "&key=" + ENV['GOOGLE_MAP_KEY']
      # Rails.logger.debug("distributing.url = #{url}")

      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      response = http.request(Net::HTTP::Get.new(uri.request_uri))
      # Rails.logger.debug("distributing.response = #{response.body}")

      json = JSON.parse(response.body)
      m_index = 0 # matrix_index
      ori_locations.each_index {|index|
        elements = json['rows'][index]['elements']
        elements.each {|e|
          matrix_location = matrix_locations[m_index]
          if matrix_location[0] != matrix_location[1]
            if e['status'].to_s == "OK"

              hash_travel = location_travels[matrix_location[0].to_s + '-' + matrix_location[1].to_s]
              meter = e['distance']['value']
              minute = (e['duration']['value'] / 60).to_i

              if hash_travel.present?
                hash_travel.distance = meter
                hash_travel.duration = minute
                hash_travel.save
                new_location_travels << hash_travel
              else
                location_travel = LocationTravel.create(location_from_id: matrix_location[0], location_to_id: matrix_location[1], distance: meter, duration: minute)
                new_location_travels << location_travel
              end
              # Rails.logger.debug("meter=" + e['distance']['value'].to_s)
              # Rails.logger.debug("minute=" + e['duration']['value'].to_s)
            end
          end

          m_index += 1
        }
      }

    end
  end

  new_location_travels
end