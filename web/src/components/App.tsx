import React, { useState } from 'react';
import './App.css';
import {debugData} from "../utils/debugData";
import {fetchNui} from "../utils/fetchNui";
import {useNuiEvent} from "../hooks/useNuiEvent";
import { faPlay,faTrash,faPlus,faMars,faVenus } from "@fortawesome/pro-solid-svg-icons";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core';
import { CharacterList } from '../interfaces/CharacterList';
import DatePicker from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";

library.add(
    faPlay,faTrash,faPlus,faMars,faVenus
)

const formatPhoneNumber = (phoneNumberString: string) => {
    var cleaned = ('' + phoneNumberString).replace(/\D/g, '');
    var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
    if (match) {
      return '(' + match[1] + ') ' + match[2] + '-' + match[3];
    }
    return "TBD";
}

const formatDate = (date:any) => {
	var d = new Date(date),
	month = '' + (d.getMonth() + 1),
	day = '' + d.getDate(),
	year = d.getFullYear();
  
	if (month.length < 2) 
	  month = '0' + month;
	if (day.length < 2) 
	  day = '0' + day;
  
	return [month, day, year].join('-');
}

const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
});

debugData([ { action: 'setVisible', data: { visible: true, vpn: true } } ])

const App: React.FC = () => {
    const [visible, setVisible] = useState(false)
    const [buttonsActive, setButtonsActive] = useState(false)
    const [formActive, setFormActive] = useState(false)
    const [popUpActive, setActivePopUp] = useState(false)
    const [Characters, setCharacters] = useState<CharacterList[]>([])
    const [ButtonType, setButtonType] = useState('')
    const [StyleState, setStyleState] = useState(-1)
    const [selectedCharacter, setSelectedCharacter] = useState(0)
    const [firstname, setFirstname] = useState("")
	const [lastname, setLastname] = useState("")
	const [gender, setGender] = useState("")
    const [nationality, setNationality] = useState("")
	const [dob, setDob] = useState("01-01-2000");
	const [date, setDate] = useState(new Date())

    useNuiEvent<boolean>('setVisible', (data:any) => {
        setVisible(data)
    })

    useNuiEvent('characters', (data:any) => {
        setCharacters(data)
    })

    useNuiEvent('removeChar', (CID) => {
        {Characters && Characters.map((data: any, key: number) => {
            const newList = Characters.filter((data:any) => data.id !== CID)
            setCharacters(newList)
            setButtonsActive(false)
            fetchNui('DeletePrevPed')
        })}
    })

	const handleFirstname = (e: any) => {
		setFirstname(e.target.value)
	}

	const handleLastname = (e: any) => {
		setLastname(e.target.value)
	}

	const handleDate = (e: any) => {
		setDate(e)
		setDob(formatDate(e))
	}

    const handleNationality = (e: any) => {
		setNationality(e.target.value)
	}

    const resetForm = () => {
        setFirstname('')
        setLastname('')
        setGender('')
        setNationality('')
        setDob('01-01-2000')
    }

    const createChar = () => {
        if (firstname.length === 0) return
		if (lastname.length === 0) return
		if (gender === "") return
        if (nationality === "") return
        
        fetchNui('createCharacter',{
            firstname: firstname,
			lastname: lastname,
			gender: gender,
			nationality: nationality,
			birthdate: dob
        })
        setFormActive(false)
        resetForm()
    }

    return (
        <div className="nui-wrapper" style={{display: visible ? '' : 'none'}}>

            <div className='pop-up-container' style={{display: popUpActive ? '' : 'none'}}>
                Are you sure you would like to delete this character?
                <div className='pop-up-buttons'>
                    <div className='pop-up-button' style={{boxShadow: '0px 2px 6px rgba(86, 253, 100, 0.5)'}} onClick={() => {fetchNui('DeleteCharacter', selectedCharacter); setActivePopUp(false)}}>Yes</div>
                    <div className='pop-up-button' style={{boxShadow: '0px 2px 6px rgba(253, 86, 86, 0.5)'}} onClick={() => {setActivePopUp(false)}}>No</div>
                </div>
            </div>

            <div className='form-container' style={{display: formActive ? '' : 'none'}}>
                <div className='form-field'>
                    <span>First Name</span>
					<input placeholder="First Name" value={firstname} onChange={handleFirstname}></input>
                </div>
                <div className='form-field'>
                    <span>Last Name</span>
					<input placeholder="Last Name" value={lastname} onChange={handleLastname}></input>
                </div>
                <div className='form-field'>
                    <span>Nationality</span>
					<input placeholder="Nationality" value={nationality} onChange={handleNationality}></input>
                </div>
                <div className="form-field">
                    <span>Gender</span>
                    <div className="genderOptions">
                        <div className='gender-box' onClick={() => setGender("m")} style={{ marginRight: '16px', zIndex: 5000, boxShadow: gender === 'm' ? '1px 2px rgba(0, 0, 0, 0.3)' : '' }}><FontAwesomeIcon fontSize={20} style={{ paddingRight: '8px' }} icon={faMars} />Male</div>
                        <div className='gender-box' onClick={() => setGender("f")} style={{ zIndex: 5000, boxShadow: gender === 'f' ? '1px 2px rgba(0, 0, 0, 0.3)' : ''  }} ><FontAwesomeIcon style={{ paddingRight: '8px' }} fontSize={20} icon={faVenus} />Female</div>
                    </div>
				</div>
                <div className="form-field">
                    <span>Date of Birth</span>
                    <DatePicker selected={date} onChange={handleDate} />
				</div>
                <div className='form-buttons'>
                    <div className='button' onClick={createChar}>Create</div>
                    <div className='button' onClick={() => {setFormActive(false); resetForm()}}>Cancel</div>
                </div>
            </div>

            <div className="charButtons" style={{display: buttonsActive ? '' : 'none'}}>
                <div className="charPlay" onClick={() => {
                    if (!formActive && !popUpActive) {
                        if (ButtonType === 'Select') {
                            fetchNui('SelectCharacter', selectedCharacter)
                        } else if (ButtonType === 'Create') {
                            setFormActive(true)
                        }
                    }
                }}><FontAwesomeIcon className='selectIcon' icon={faPlay} />{ButtonType}</div>
                <div className="charDelete" onClick={() => {if (!formActive && !popUpActive) { setActivePopUp(true)}}} style={{display: ButtonType === 'Select' ? '' : 'none'}}><FontAwesomeIcon className='deleteIcon' icon={faTrash} />Delete</div>
            </div>

            <div className='characters-containers'>
                <div className="characters">
                    {Characters && Characters.map((data: any, key: number) => {
                        return <div className="charData" key={key} style={{ boxShadow: StyleState === key ? 'inset 0 -3px 0 #d92121' : '', backgroundColor: StyleState === key ? 'rgba(0, 0, 0, 0.5)' : ''  }} onClick={() => {
                            if (!formActive && !popUpActive) {
                                console.log(popUpActive)
                                if (ButtonType === '' || ButtonType === 'Create' || ButtonType === 'Select') {
                                    setStyleState(key); setButtonsActive(true); setButtonType('Select'); fetchNui('DeletePrevPed'); setTimeout(() => {}, 200); fetchNui('CurrentCharacter', data.id); setSelectedCharacter(data)
                                } else if (ButtonType === 'Select'  || ButtonType === 'Create'){
                                    setStyleState(-1); setButtonsActive(false); setButtonType(''); fetchNui('DeletePrevPed'); setSelectedCharacter(0)
                                }}}
                            }>
                            <div className="charName">{data.name}</div>
                            <div className="charDOB">DOB : {data.birthdate}</div>
                            <div className="charID">ID : {data.id}</div>
                            <div className="charPhone"># {formatPhoneNumber(data.phone)}</div>
                            <div className="charBank">{formatter.format(data.bank)}</div>
                        </div>
                    })}
                    {[...Array(4-Characters.length)].map((e, i) => <div className="BlankCharacter" key={i} style={{ boxShadow: StyleState === i+3 ? 'inset 0 -3px 0 #d92121' : '', backgroundColor: StyleState === i+3 ? 'rgba(0, 0, 0, 0.5)' : '' }} onClick={() => {
                        if (!formActive && !popUpActive) {
                            if (ButtonType === '' || ButtonType === 'Select' || ButtonType === 'Create') {
                                setSelectedCharacter(0); setStyleState(i+3); setButtonsActive(true); setButtonType('Create'); fetchNui('DeletePrevPed'); setTimeout(() => {}, 200);  fetchNui('CurrentCharacter')
                            } else if (ButtonType === 'Create' || ButtonType === 'Select'){
                                setSelectedCharacter(0); setStyleState(-1); setButtonsActive(false); setButtonType(''); fetchNui('DeletePrevPed')
                            }
                        }
                    }}><FontAwesomeIcon className='plusIcon' icon={faPlus} /></div>)}
                </div>
            </div>
        </div>
        
    );
}

export default App;


